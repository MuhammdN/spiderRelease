import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:typed_data'; // Add this import for Uint8List

class SocialApp {
  final String name;
  final dynamic icon; // Can be IconData or Uint8List for app icons
  final Color color;
  final List<String>? launchUrls;
  final String packageName;
  final String? fallbackUrl;
  final String category;

  SocialApp({
    required this.name,
    required this.icon,
    required this.color,
    required this.packageName,
    this.launchUrls,
    this.fallbackUrl,
    this.category = 'Social',
  });

  Widget getIconWidget({double size = 24.0, Color? iconColor}) {
    if (icon is IconData) {
      return Icon(icon as IconData, size: size, color: iconColor);
    } else if (icon is Uint8List) {
      return Image.memory(
        icon as Uint8List,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, size: size, color: Colors.red),
      );
    } else if (icon is List<int>) {
      // Convert List<int> to Uint8List if needed
      return Image.memory(
        Uint8List.fromList(icon as List<int>),
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, size: size, color: Colors.red),
      );
    }
    return Icon(Icons.error, size: size, color: Colors.red);
  }
}

// Your allSocialApps list remains the same as before
final List<SocialApp> allSocialApps = [
  SocialApp(
    name: 'Facebook',
    icon: FontAwesomeIcons.facebookF,
    color: const Color(0xFF3b5998),
    packageName: 'com.facebook.katana',
    launchUrls: ['fb://', 'fb://profile'],
    fallbackUrl: 'https://apps.apple.com/app/facebook/id284882215',
  ),
  SocialApp(
    name: 'WhatsApp',
    icon: FontAwesomeIcons.whatsapp,
    color: const Color(0xFF25D366),
    packageName: 'com.whatsapp',
    launchUrls: ['whatsapp://'],
    fallbackUrl: 'https://apps.apple.com/app/whatsapp-messenger/id310633997',
  ),
  SocialApp(
    name: 'Instagram',
    icon: FontAwesomeIcons.instagram,
    color: const Color(0xFFE1306C),
    packageName: 'com.instagram.android',
    launchUrls: ['instagram://app'],
    fallbackUrl: 'https://apps.apple.com/app/instagram/id389801252',
  ),
  SocialApp(
    name: 'TikTok',
    icon: FontAwesomeIcons.tiktok,
    color: const Color(0xFF010101),
    packageName: 'com.zhiliaoapp.musically',
    launchUrls: ['snssdk1128://'],
    fallbackUrl: 'https://apps.apple.com/app/tiktok/id835599320',
  ),
  SocialApp(
    name: 'YouTube',
    icon: FontAwesomeIcons.youtube,
    color: const Color(0xFFFF0000),
    packageName: 'com.google.android.youtube',
    launchUrls: ['youtube://'],
    fallbackUrl: 'https://apps.apple.com/app/youtube-watch-listen-stream/id544007664',
  ),
  SocialApp(
    name: 'Twitter (X)',
    icon: FontAwesomeIcons.xTwitter,
    color: const Color(0xFF000000),
    packageName: 'com.twitter.android',
    launchUrls: ['twitter://'],
    fallbackUrl: 'https://apps.apple.com/app/x/id333903271',
  ),
  SocialApp(
    name: 'Snapchat',
    icon: FontAwesomeIcons.snapchatGhost,
    color: const Color(0xFFFFFC00),
    packageName: 'com.snapchat.android',
    launchUrls: ['snapchat://'],
    fallbackUrl: 'https://apps.apple.com/app/snapchat/id447188370',
  ),
  SocialApp(
    name: 'LinkedIn',
    icon: FontAwesomeIcons.linkedinIn,
    color: const Color(0xFF0077B5),
    packageName: 'com.linkedin.android',
    launchUrls: ['linkedin://'],
    fallbackUrl: 'https://apps.apple.com/app/linkedin/id288429040',
  ),
  SocialApp(
    name: 'Telegram',
    icon: FontAwesomeIcons.telegram,
    color: const Color(0xFF0088cc),
    packageName: 'org.telegram.messenger',
    launchUrls: ['tg://'],
    fallbackUrl: 'https://apps.apple.com/app/telegram-messenger/id686449807',
  ),
  SocialApp(
    name: 'Pinterest',
    icon: FontAwesomeIcons.pinterestP,
    color: const Color(0xFFE60023),
    packageName: 'com.pinterest',
    launchUrls: ['pinterest://'],
    fallbackUrl: 'https://apps.apple.com/app/pinterest/id429047995',
  ),
  SocialApp(
    name: 'Spotify',
    icon: FontAwesomeIcons.spotify,
    color: const Color(0xFF1DB954),
    packageName: 'com.spotify.music',
    launchUrls: ['spotify://'],
    fallbackUrl: 'https://apps.apple.com/app/spotify-music-and-podcasts/id324684580',
  ),
  SocialApp(
    name: 'Netflix',
    icon: FontAwesomeIcons.star,
    color: const Color(0xFFE50914),
    packageName: 'com.netflix.mediaclient',
    launchUrls: ['nflx://'],
    fallbackUrl: 'https://apps.apple.com/app/netflix/id363590051',
  ),
  SocialApp(
    name: 'Google Maps',
    icon: FontAwesomeIcons.mapLocationDot,
    color: const Color(0xFF4285F4),
    packageName: 'com.google.android.apps.maps',
    launchUrls: ['comgooglemaps://'],
    fallbackUrl: 'https://apps.apple.com/app/google-maps/id585027354',
  ),
  SocialApp(
    name: 'Amazon',
    icon: FontAwesomeIcons.amazon,
    color: const Color(0xFFFF9900),
    packageName: 'com.amazon.mShop.android.shopping',
    launchUrls: ['amazon://'],
    fallbackUrl: 'https://apps.apple.com/app/amazon-shopping/id297606951',
  ),
  SocialApp(
    name: 'Google Chrome',
    icon: FontAwesomeIcons.chrome,
    color: const Color(0xFF4285F4),
    packageName: 'com.android.chrome',
    launchUrls: ['googlechrome://'],
    fallbackUrl: 'https://apps.apple.com/app/google-chrome/id535886823',
  ),
  SocialApp(
    name: 'Zoom',
    icon: FontAwesomeIcons.video,
    color: const Color(0xFF2D8CFF),
    packageName: 'us.zoom.videomeetings',
    launchUrls: ['zoomus://'],
    fallbackUrl: 'https://apps.apple.com/app/zoom-one-platform-to-connect/id546505307',
  ),
  SocialApp(
    name: 'Uber',
    icon: FontAwesomeIcons.uber,
    color: const Color(0xFF000000),
    packageName: 'com.ubercab',
    launchUrls: ['uber://'],
    fallbackUrl: 'https://apps.apple.com/app/uber/id368677368',
  ),
  SocialApp(
    name: 'Gmail',
    icon: FontAwesomeIcons.envelope,
    color: const Color(0xFFEA4335),
    packageName: 'com.google.android.gm',
    launchUrls: ['googlegmail://'],
    fallbackUrl: 'https://apps.apple.com/app/gmail-email-by-google/id422689480',
  ),
  SocialApp(
    name: 'Discord',
    icon: FontAwesomeIcons.discord,
    color: const Color(0xFF5865F2),
    packageName: 'com.discord',
    launchUrls: ['discord://'],
    fallbackUrl: 'https://apps.apple.com/app/discord/id985746746',
  ),
  SocialApp(
    name: 'Reddit',
    icon: FontAwesomeIcons.redditAlien,
    color: const Color(0xFFFF4500),
    packageName: 'com.reddit.frontpage',
    launchUrls: ['reddit://'],
    fallbackUrl: 'https://apps.apple.com/app/reddit/id1064216828',
  ),
];