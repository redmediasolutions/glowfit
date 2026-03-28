import 'package:flutter/material.dart';
import 'package:glowfit/components/products_List.dart';
import 'package:glowfit/models/product_model.dart';
import 'package:glowfit/services/api.dart';
import 'package:go_router/go_router.dart';

class HorizontalCollection extends StatelessWidget {
    final String categoryId; 


  const HorizontalCollection({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: FutureBuilder<List<Productsmodel>>(
        future: APIService.fetchProductsByCategory(categoryId: categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingList();
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load products',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 10),
           itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () => context.push('/productview', extra: product),
              child: Container(
                width: 320,
              
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                   Padding(
            padding: const EdgeInsets.all(30.0),
            child: ProductsList(
              product: product,
              id: product.id.toString(),
              name: product.name,
              imageUrl: product.image,
              regularPrice: product.regularPrice,
              onAddToCart: () => print("Added ${product.name}"),
            ),
          ),
                    Positioned(
                      top: 25,
                      right: 25,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                           context.push('/productview', extra: product);
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        }
      ),
    );
}
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, _) {
        return Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}