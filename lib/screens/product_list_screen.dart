import 'dart:convert';

import 'package:crud_app_using_api/models/product.dart';
import 'package:crud_app_using_api/screens/add_new_product_screen.dart';
import 'package:crud_app_using_api/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> productList = [];
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    getProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
        actions: [
          IconButton(
            onPressed: getProductList,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _inProgress
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  return ProductItem(
                    product: productList[index],
                    onDelete: deleteProduct,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddNewProductScreen();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> getProductList() async {
    _inProgress = true;
    setState(() {});
    Uri uri = Uri.parse("http://164.68.107.70:6060/api/v1/ReadProduct");
    Response response = await get(uri);
    print(response);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      productList.clear();
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      for (var item in jsonResponse["data"]) {
        Product product = Product(
            id: item["_id"] ?? "",
            productName: item["ProductName"] ?? "",
            productCode: item["ProductCode"] ?? "",
            img: item["Img"] ?? "",
            unitPrice: item["UnitPrice"] ?? "",
            qty: item["Qty"] ?? "",
            totalPrice: item["TotalPrice"] ?? "",
            createdDate: item["CreatedDate"] ?? "");
        productList.add(product);
      }
    }
    _inProgress = false;
    setState(() {});
  }

  Future<void> deleteProduct(String id) async {
    setState(() {
      _inProgress = true;
    });

    Uri uri = Uri.parse("http://164.68.107.70:6060/api/v1/DeleteProduct/$id");
    Response response = await get(uri);
    if (response.statusCode == 200) {
      getProductList();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product Deleted")));
    }
    setState(() {
      _inProgress = false;
    });
  }
}
