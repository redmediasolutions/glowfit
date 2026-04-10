import { onCall, onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import Razorpay from "razorpay";
import * as crypto from "crypto";
import axios from "axios";
import { Request, Response } from "express";

admin.initializeApp();

// =======================================================
// 🔐 CONFIG
// =======================================================

const FREE_SHIPPING_THRESHOLD = 499;
const SHIPPING_BELOW_THRESHOLD = 49;
const SHIPPING_ABOVE_THRESHOLD = 0;
const TAX_PERCENTAGE = 0.05;
const COD_CHARGE = 60;

// =======================================================
// 📦 GET CART RATES
// =======================================================

export const getCartRates = onCall(async (request) => {
  const paymentMethod = request.data.paymentMethod || "online";

  return {
    freeShippingThreshold: FREE_SHIPPING_THRESHOLD,
    shippingBelowThreshold: SHIPPING_BELOW_THRESHOLD,
    shippingAboveThreshold: SHIPPING_ABOVE_THRESHOLD,
    taxPercentage: TAX_PERCENTAGE,
    codCharge: paymentMethod === "cod" ? COD_CHARGE : 0,
  };
});

// =======================================================
// 🛒 CREATE SECURE ORDER
// =======================================================

export const createSecureOrder = onCall(async (request) => {
  if (!request.auth) throw new Error("Unauthenticated");

  const uid = request.auth.uid;
  const paymentMethod = request.data.paymentMethod;

  const cartSnap = await admin
    .firestore()
    .collection("carts")
    .doc(uid)
    .collection("items")
    .get();

  if (cartSnap.empty) throw new Error("Cart is empty");

  let subtotal = 0;

  cartSnap.forEach((doc) => {
    const item = doc.data();
    subtotal += (item.salePrice || 0) * (item.quantity || 1);
  });

  const shipping =
    subtotal <= FREE_SHIPPING_THRESHOLD
      ? SHIPPING_BELOW_THRESHOLD
      : SHIPPING_ABOVE_THRESHOLD;

  const tax = subtotal * TAX_PERCENTAGE;
  const codCharge = paymentMethod === "cod" ? COD_CHARGE : 0;

  const finalPayable = subtotal + shipping + tax + codCharge;

  let razorpayOrderId: string | null = null;

  if (paymentMethod === "online" && finalPayable > 0) {
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY!,
      key_secret: process.env.RAZORPAY_SECRET!,
    });

    const order = await razorpay.orders.create({
      amount: Math.round(finalPayable * 100),
      currency: "INR",
      receipt: `order_${Date.now()}`,
    });

    razorpayOrderId = order.id;
  }

  return {
    subtotal,
    shipping,
    tax,
    codCharge,
    finalPayable,
    razorpayOrderId,
  };
});

// =======================================================
// 💳 FINALIZE ORDER
// =======================================================

export const finalizeOrder = onCall(async (request) => {
  if (!request.auth) throw new Error("Unauthenticated");

  const uid = request.auth.uid;

  const {
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature,
    billing,
    shipping,
  } = request.data || {};

  // 🔐 Verify Razorpay
  if (razorpayOrderId && razorpayPaymentId && razorpaySignature) {
    const body = razorpayOrderId + "|" + razorpayPaymentId;

    const expected = crypto
      .createHmac("sha256", process.env.RAZORPAY_SECRET!)
      .update(body)
      .digest("hex");

    if (expected !== razorpaySignature) {
      throw new Error("Invalid payment signature");
    }
  }

  const cartRef = admin
    .firestore()
    .collection("carts")
    .doc(uid)
    .collection("items");

  const cartSnap = await cartRef.get();

  if (cartSnap.empty) throw new Error("Cart empty");

  let subtotal = 0;

  cartSnap.forEach((doc) => {
    const item = doc.data();
    subtotal += (item.salePrice || 0) * (item.quantity || 1);
  });

  const shippingAmount =
    subtotal <= FREE_SHIPPING_THRESHOLD
      ? SHIPPING_BELOW_THRESHOLD
      : SHIPPING_ABOVE_THRESHOLD;

  const tax = subtotal * TAX_PERCENTAGE;

  const wooOrder = await createWooOrder({
    uid,
    cartSnap,
    subtotal,
    shipping: shippingAmount,
    tax,
    paymentMethod: razorpayPaymentId ? "online" : "cod",
    billing,
    shippingAddress: shipping,
  });

  const wooOrderId = wooOrder.id;

  await admin.firestore().runTransaction(async (transaction) => {
    cartSnap.forEach((doc) => transaction.delete(doc.ref));

    const orderRef = admin
      .firestore()
      .collection("Orders")
      .doc(String(wooOrderId));

    transaction.set(orderRef, {
      uid,
      wooOrderId,
      subtotal,
      shipping: shippingAmount,
      tax,
      paymentMethod: razorpayPaymentId ? "online" : "cod",
      paymentStatus: razorpayPaymentId ? "paid" : "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {
    success: true,
    orderId: wooOrderId,
  };
});

// =======================================================
// 🌐 WOO WEBHOOK
// =======================================================

export const wooOrderStatusWebhook = onRequest(
  async (req: Request, res: Response): Promise<void> => {
    try {
      const order = req.body;

      if (!order?.id) {
        res.status(400).send("Invalid");
        return; // ✅ important
      }

      await admin
        .firestore()
        .collection("Orders")
        .doc(String(order.id))
        .update({
          status: order.status,
        });

      res.status(200).send("OK");
      return; // ✅ explicit return
    } catch (e) {
      console.error(e);
      res.status(500).send("Error");
      return; // ✅ required
    }
  }
);

// =======================================================
// 🛒 CREATE WOO ORDER
// =======================================================

async function createWooOrder({
  uid,
  cartSnap,
  subtotal,
  shipping,
  tax,
  paymentMethod,
  billing,
  shippingAddress,
}: any) {
  const lineItems: any[] = [];

  cartSnap.forEach((doc: any) => {
    const item = doc.data();
    lineItems.push({
      product_id: item.productId,
      quantity: item.quantity || 1,
    });
  });

  const body = {
    payment_method: paymentMethod === "online" ? "razorpay" : "cod",
    set_paid: paymentMethod === "online",
    billing,
    shipping: shippingAddress,
    line_items: lineItems,
    shipping_lines: [
      {
        method_title: "Standard Shipping",
        total: shipping.toFixed(2),
      },
    ],
    tax_lines: [
      {
        label: "GST",
        tax_total: tax.toFixed(2),
      },
    ],
    meta_data: [{ key: "app_uid", value: uid }],
  };

  const response = await axios.post(
    "https://gs.redmediasolutions.in/wp-json/wc/v3/orders",
    body,
    {
      auth: {
        username: "ck_1f90c93d45a4593f00f89ba5c942001e13898e09",
        password: "cs_1c4ddd44c08c3399ecbca3e6e16f1234274ae392",
      },
    }
  );

  return response.data;
}