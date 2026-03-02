import 'package:flutter/material.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Software Development',
    'Design & Branding',
    'Data & Analytics',
    'Consulting',
    'Cloud & Infrastructure',
    'Marketing & E-commerce',
  ];

  final List<Map<String, dynamic>> _companies = [
    {
      'name': 'TechCore Solutions',
      'rating': 4.5,
      'reviews': 128,
      'category': 'Software Development',
      'description': 'Leading software development company delivering innovative tech solutions across Nepal and Southeast Asia.',
      'location': 'Kathmandu, Nepal',
      'openJobs': 12,
      'logo': Icons.computer,
      'logoColor': Color(0xFF2563EB),
      'logoBg': Color(0xFFEFF6FF),
    },
    {
      'name': 'Creative Minds',
      'rating': 4.7,
      'reviews': 95,
      'category': 'Design & Branding',
      'description': 'Digital agency specializing in UX/UI design, branding, and web development for startups and enterprises.',
      'location': 'Lalitpur, Nepal',
      'openJobs': 8,
      'logo': Icons.brush,
      'logoColor': Color(0xFF7C3AED),
      'logoBg': Color(0xFFF5F3FF),
    },
    {
      'name': 'DataNova Analytics',
      'rating': 4.3,
      'reviews': 61,
      'category': 'Data & Analytics',
      'description': 'Empowering businesses with data-driven insights, machine learning models, and business intelligence solutions.',
      'location': 'Kathmandu, Nepal',
      'openJobs': 5,
      'logo': Icons.bar_chart,
      'logoColor': Color(0xFF059669),
      'logoBg': Color(0xFFECFDF5),
    },
    {
      'name': 'NepCloud Systems',
      'rating': 4.6,
      'reviews': 44,
      'category': 'Cloud & Infrastructure',
      'description': 'Cloud infrastructure and DevOps solutions provider helping companies scale securely and efficiently.',
      'location': 'Pokhara, Nepal',
      'openJobs': 7,
      'logo': Icons.cloud,
      'logoColor': Color(0xFF0EA5E9),
      'logoBg': Color(0xFFF0F9FF),
    },
    {
      'name': 'BizConsult Nepal',
      'rating': 4.2,
      'reviews': 37,
      'category': 'Consulting',
      'description': 'Strategic business consulting firm offering management advisory, financial planning, and market research.',
      'location': 'Bhaktapur, Nepal',
      'openJobs': 3,
      'logo': Icons.business_center,
      'logoColor': Color(0xFFF59E0B),
      'logoBg': Color(0xFFFFFBEB),
    },
    {
      'name': 'DigitalMart Nepal',
      'rating': 4.4,
      'reviews': 82,
      'category': 'Marketing & E-commerce',
      'description': 'Full-service digital marketing and e-commerce agency helping brands grow their online presence in Nepal.',
      'location': 'Kathmandu, Nepal',
      'openJobs': 10,
      'logo': Icons.shopping_cart,
      'logoColor': Color(0xFFEF4444),
      'logoBg': Color(0xFFFEF2F2),
    },
    {
      'name': 'PixelForge Studio',
      'rating': 4.8,
      'reviews': 53,
      'category': 'Design & Branding',
      'description': 'Award-winning design studio crafting visually stunning brand identities, product designs, and campaigns.',
      'location': 'Lalitpur, Nepal',
      'openJobs': 4,
      'logo': Icons.palette,
      'logoColor': Color(0xFFDB2777),
      'logoBg': Color(0xFFFDF2F8),
    },
    {
      'name': 'CodeCraft IT',
      'rating': 4.1,
      'reviews': 29,
      'category': 'Software Development',
      'description': 'Custom software and mobile app development company focused on delivering quality products for SMEs.',
      'location': 'Biratnagar, Nepal',
      'openJobs': 6,
      'logo': Icons.code,
      'logoColor': Color(0xFF2563EB),
      'logoBg': Color(0xFFEFF6FF),
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _companies.where((c) {
      final matchCategory = _selectedCategory == 'All' || c['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),
                  Text(
                    'Showing ${filtered.length} compan${filtered.length == 1 ? 'y' : 'ies'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGrid(filtered),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Discover Top ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Companies in Nepal',
                  style: TextStyle(color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore leading organizations, learn about their culture, and find exciting career opportunities.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: const InputDecoration(
          hintText: 'Search companies by name...',
          hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF64748B)),
          ),
          ..._categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> companies) {
    if (companies.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Color(0xFFCBD5E1)),
              SizedBox(height: 12),
              Text(
                'No companies found',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: companies.length,
      itemBuilder: (context, index) => _CompanyCard(company: companies[index]),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Map<String, dynamic> company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: company['logoBg'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  company['logo'] as IconData,
                  color: company['logoColor'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company['name'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${company['rating']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        Text(
                          ' (${company['reviews']})',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (company['logoBg'] as Color),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              company['category'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: company['logoColor'] as Color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            company['description'],
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  company['location'],
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.work_outline, size: 12, color: Color(0xFF2563EB)),
              const SizedBox(width: 2),
              Text(
                '${company['openJobs']} Open Jobs',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}