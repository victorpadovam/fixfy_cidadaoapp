import 'package:fixfycidadaoapp/view/rive_app/components/hcard.dart';
import 'package:fixfycidadaoapp/view/rive_app/components/vcard.dart';
import 'package:fixfycidadaoapp/view/rive_app/models/courses.dart';
import 'package:fixfycidadaoapp/view/rive_app/theme.dart';
import 'package:flutter/material.dart';

class DealModel {
  final String id;
  final String title;
  final String image;
  final String time;
  final String distance;
  final double rating;
  final String promo;
  final bool isTrending;
  final bool hasNoComplaints;
  final String? specialOffer;

  DealModel({
    required this.id,
    required this.title,
    required this.image,
    required this.time,
    required this.distance,
    required this.rating,
    required this.promo,
    this.isTrending = false,
    this.hasNoComplaints = false,
    this.specialOffer,
  });

  static List<DealModel> mocks = [
    DealModel(
      id: '1',
      title: "McDonald's",
      image: "https://images.unsplash.com/photo-1550547660-d9450f859349",
      time: "25-30 mins",
      distance: "4.4 km",
      rating: 4.5,
      promo: "Buy 2 Get 1 Free",
      isTrending: true,
    ),
    DealModel(
      id: '2',
      title: "McDonald's",
      image: "https://images.unsplash.com/photo-1550547660-d9450f859349",
      time: "25-30 mins",
      distance: "4.4 km",
      rating: 4.5,
      promo: "Last 100 Orders Without Complaints",
      hasNoComplaints: true,
    ),
    DealModel(
      id: '3',
      title: "McDonald's",
      image: "https://images.unsplash.com/photo-1550547660-d9450f859349",
      time: "25-30 mins",
      distance: "4.4 km",
      rating: 4.5,
      promo: "Last 100 Orders Without Complaints",
      hasNoComplaints: true,
      specialOffer: "Flat \$19 OFF above \$150",
    ),
    DealModel(
      id: '4',
      title: "Burger King",
      image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
      time: "20-25 mins",
      distance: "3.2 km",
      rating: 4.3,
      promo: "20% OFF",
    ),
  ];
}

class DealCard extends StatelessWidget {
  final DealModel deal;

  const DealCard({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 IMAGEM
          Stack(
            children: [
              // Container que define as bordas arredondadas
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: Image.network(
                  deal.image,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 130,
                      color: Colors.grey[200],
                      child: const Center(
                        child:
                            Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

              // Badge Trending
              if (deal.isTrending)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Trending",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 🔹 CONTEÚDO (PARTE BRANCA)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha 1: Tempo e distância (COM PONTO CENTRALIZADO)
                Text(
                  "${deal.time} . ${deal.distance}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Linha 2: Nome do restaurante + Rating (NA MESMA LINHA)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nome com emoji de hambúrguer
                    Row(
                      children: [
                        Text(
                          deal.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "🍔",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    // Rating com estrela
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deal.rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Linha 3: Promoção principal (SEM ÍCONE, APENAS TEXTO)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      deal.promo,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Oferta especial (se existir)
                if (deal.specialOffer != null &&
                    deal.specialOffer!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Center(
                      child: Text(
                        deal.specialOffer!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final List<CourseModel> _courses = CourseModel.courses;
  final List<CourseModel> _courseSections = CourseModel.courseSections;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RiveAppTheme.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 SUPER DEALS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Super Deals",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "See all",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children:
                  DealModel.mocks.map((deal) => DealCard(deal: deal)).toList(),
            ),
          ),

          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Courses",
              style: TextStyle(
                fontSize: 22,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ..._courses.map(
                (course) => Padding(
                  key: course.id,
                  padding: const EdgeInsets.all(10),
                  child: VCard(course: course),
                ),
              )
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Text(
              "Recent",
              style: TextStyle(
                fontSize: 22,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...List.generate(
            _courseSections.length,
            (index) => Padding(
              key: _courseSections[index].id,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: HCard(section: _courseSections[index]),
            ),
          )
        ],
      ),
    );
  }
}
