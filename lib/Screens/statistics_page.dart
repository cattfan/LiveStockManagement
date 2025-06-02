// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  // SVG strings
  final String piggyBankSvg = '''
    <svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256">
      <path d="M192,116a12,12,0,1,1-12-12A12,12,0,0,1,192,116ZM152,64H112a8,8,0,0,0,0,16h40a8,8,0,0,0,0-16Zm96,48v32a24,24,0,0,1-24,24h-2.36l-16.21,45.38A16,16,0,0,1,190.36,224H177.64a16,16,0,0,1-15.07-10.62L160.65,208h-57.3l-1.92,5.38A16,16,0,0,1,86.36,224H73.64a16,16,0,0,1-15.07-10.62L46,178.22a87.69,87.69,0,0,1-21.44-48.38A16,16,0,0,0,16,144a8,8,0,0,1-16,0,32,32,0,0,1,24.28-31A88.12,88.12,0,0,1,112,32H216a8,8,0,0,1,0,16H194.61a87.93,87.93,0,0,1,30.17,37c.43,1,.85,2,1.25,3A24,24,0,0,1,248,112Zm-16,0a8,8,0,0,0-8-8h-3.66a8,8,0,0,1-7.64-5.6A71.9,71.9,0,0,0,144,48H112A72,72,0,0,0,58.91,168.64a8,8,0,0,1,1.64,2.71L73.64,208H86.36l3.82-10.69A8,8,0,0,1,97.71,192h68.58a8,8,0,0,1,7.53,5.31L177.64,208h12.72l18.11-50.69A8,8,0,0,1,216,152h8a8,8,0,0,0,8-8Z"/>
    </svg>
  ''';

  final String birdSvg = '''
    <svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256">
      <path d="M176,68a12,12,0,1,1-12-12A12,12,0,0,1,176,68Zm-50.88,61.85a8,8,0,0,0-11.27,1l-40,48a8,8,0,0,0,12.3,10.24l40-48A8,8,0,0,0,125.12,129.85ZM240,80a8,8,0,0,1-3.56,6.66L216,100.28V120A104.11,104.11,0,0,1,112,224H8a8,8,0,0,1-6.25-13L96,93.19V76A60,60,0,0,1,213.21,57.86l23.23,15.48A8,8,0,0,1,240,80Zm-22.42,0L201.9,69.54a8,8,0,0,1-3.31-4.64A44,44,0,0,0,112,76V96a8,8,0,0,1-1.75,5L24.64,208H112a88.1,88.1,0,0,0,88-88V96a8,8,0,0,1,3.56-6.66Z"/>
    </svg>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Thống kê', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyCustomListItem(
              svgIconString: piggyBankSvg,
              title: 'Gia súc',
              subtitle: '80 con',
              iconBackgroundColor: const Color(0xFFEBF2E9),
              iconColor: const Color(0xFF111A0F),
              subtitleColor: const Color(0xFF629155),
            ),
            MyCustomListItem(
              svgIconString: birdSvg,
              title: 'Gia Cầm',
              subtitle: '500 con',
              iconBackgroundColor: const Color(0xFFEBF2E9),
              iconColor: const Color(0xFF111A0F),
              subtitleColor: const Color(0xFF629155),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Thức ăn và vật tư',
                style: TextStyle(
                  color: Color(0xFF111A0F),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.27,
                  letterSpacing: -0.33,
                ),
              ),
            ),
            MyCustomListItem(
              iconData: Icons.grain,
              title: 'Thức ăn chăn nuôi',
              subtitle: '500 kg',
              iconBackgroundColor: const Color(0xFFEBF2E9),
              iconColor: const Color(0xFF111A0F),
              subtitleColor: const Color(0xFF629155),
            ),
            MyCustomListItem(
              iconData: Icons.water,
              title: 'Nước',
              subtitle: '100 lít',
              iconBackgroundColor: const Color(0xFFEBF2E9),
              iconColor: const Color(0xFF111A0F),
              subtitleColor: const Color(0xFF629155),
            ),
            MyCustomListItem(
              iconData: Icons.medical_services,
              title: 'Tiêm Chủng',
              subtitle: '100 cái',
              iconBackgroundColor: const Color(0xFFEBF2E9),
              iconColor: const Color(0xFF111A0F),
              subtitleColor: const Color(0xFF629155),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomListItem extends StatelessWidget {
  final String? svgIconString;
  final IconData? iconData;
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color subtitleColor;

  const MyCustomListItem({
    super.key,
    this.svgIconString,
    this.iconData,
    required this.title,
    required this.subtitle,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.subtitleColor,
  }) : assert(svgIconString != null || iconData != null, 'Either svgIconString or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(minHeight: 72),
      decoration: const BoxDecoration(color: Color(0xFFF9FBF9)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: iconBackgroundColor,
            ),
            child: Center(
              child: svgIconString != null
                  ? SvgPicture.string(
                      svgIconString!,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    )
                  : Icon(iconData, size: 24, color: iconColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111A0F),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
