// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mterminal/models/host.dart';

void main() {
  test('list json parsing', () {
    const str =
        '[{"id":1,"name":"prod-los","address":"10.0.3.91","port":22,"username":"ubuntu","deleted_on":null,"identity":{"id":4,"name":"progcap-prod-keypair","type":2,"password":null,"private_key":"-----BEGIN RSA PRIVATE KEY-----MIIEoAIBAAKCAQEAi3kti5vfAnDR0C04RG1pG+VCtORZZuPBJbfITu+XbSJ4Sfw+Hi8vhQc6JPx9Bq4JegtmDvvjWzTfb631uidwHdnHqSQYBOaB+TqGKrG/loxfnFFax2AwPL3mCVxtnr76d5i3iwtP96z7USEpm8yEZJ/0hEysGDITJNo/6Fhrxrm8bEcTJRimW2WisBJsY0fvZuwS/T8dxZHLJsKChi2N1zwzsI20/U2iC9RbShuOC/evI1npZGhRknhaqKI3KMfOLtt66GzzuTSd8vfJ1Z14XzBWGv7UAEgANgDBcT/ZVQRR9rrrLgupzrMGoLXyMogYEFYJuzjSpumfqB95+JXKxwIDAQABAoH/MHzwWJjX7wFJ8BXIegGPiSMrDbhVXG/RtksuWELzYf2Z1B7deaDt5FGe5TziOnBG2ycbVBo98HdxNmJEC3OqhrYvs53Yu9tnVD4EZtNkx/IFS1L9PFM0cemTD64Sbh329Z0iMjS8mF6LAKmGzaNMY684UsZVDhRak3VMwnn6/hsQIl1ZQEEwREpLelQdGStmYC5k818Y2Ro9wAnFTUrytf5bGYWEOrG8iXAB67UW18gyKMotToOjAMFIadmkyW3FDIYQRtZvXVeLU4XlGv/qvgBdLzyo+dI/Z65rTONPLA8QSHGXRt5HN2bo0FK8aSbXTQFlt5oO+K+0RY+BgDBhAoGBANQmw0VGlJFXVGRMp4ucLY+urt0g5hdejp679H1ESRWdlCDe7xnJl+zDwqGFCW//NlIGHzo2EicpEwsaTf1PLcN4OYgOkN0ouDheE2qEoOfMXiJeEAmtDlsmce4Z15SMv7EbkPVHxBTMRZKBg42vr05YgSqvKzHc2SpIlKByOLBXAoGBAKhM6fc+lBOEIOMCs/aPowIbPd8wb+YhZ5dEm5+a4N/D5EkzxRp7A3g2T3DURd0vpHzsXxw0+kiQieHEmRhglZCHxCRS8+22hUnFmPMU4pzSVjYUX2rKpk4eJOeHbEScECzRE0/fNLoovaGGFAwbnokiszkDbTHWTcvJNTKEXXMRAoGAQ8NB2e3KZIYVYZgOaAxxjRRJrD3m4I4GVfNJC331Lh9QAhPTIVR/31ND5p18vzYwXpCwBsLgl3uKJqC3SnKw9l9/WNL2OH3aIb8CyqIkVwWzB50t2DlbfYfRGjFM55jxXZuleIL8wXvhuQL/RxFXmFmyoDSlQl79SoE2X+076C8CgYAnhkCgBvtBhhMvHPBkpCD1Gq6yHq74zbmFReCCYB4Vjuyq4FSWvnL3JVIMvl1V751ilSRU/IAW0JMBCWmm1u/pDGlc2npcxjOROq2L0MjTaXZDpw8thj/+MogaM6yShFAsJkGxzUqVuYGnUFSe71GRBSwv5IUdYiXNCQjMP1eu8QKBgDD5aIhKculQN+HXEv+JK76H8c+vcIHvoHNM3GjTfoDeGLV/8ybYTVHvjyZ4N476CPbSQ6ezojkzY+nfJz2lnmYNez/KrHDUqTRSd2iO4roslOXtl16hwFr5elFyXB1LXmGZwGIu9sYPnlruUzGrVIOCagajJWPrseRi4NuAqfkV-----END RSA PRIVATE KEY-----","deleted_on":null}}]';
    final listJson = jsonDecode(str) as List;
    print(listJson.map((e) => Host.fromJson(e as Map<String, dynamic>)).toList());
  });
}
