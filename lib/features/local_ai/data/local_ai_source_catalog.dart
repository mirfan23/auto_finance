/// Package names for popular Indonesian consumer banking and wallet apps.
///
/// The list is a convenience catalog, not an allowlist: apps discovered from
/// notification history are merged into it by the settings page.
class LocalAiSourceCatalog {
  const LocalAiSourceCatalog._();

  static const banks = <Map<String, String>>[
    {'label': 'BCA mobile', 'packageName': 'com.bca'},
    {'label': 'myBCA', 'packageName': 'com.bca.mybca.omni.android'},
    {'label': 'BRImo', 'packageName': 'id.co.bri.brimo'},
    {'label': 'Livin’ by Mandiri', 'packageName': 'id.bmri.livin'},
    {'label': 'wondr by BNI', 'packageName': 'id.bni.wondr'},
    {'label': 'BNI Mobile Banking (lama)', 'packageName': 'src.com.bni'},
    {'label': 'BYOND by BSI', 'packageName': 'co.id.bankbsi.superapp'},
    {'label': 'BSI Mobile (lama)', 'packageName': 'com.bsm.activity2'},
    {'label': 'Jago', 'packageName': 'com.jago.digitalBanking'},
    {'label': 'blu by BCA Digital', 'packageName': 'com.bcadigital.blu'},
    {'label': 'SeaBank', 'packageName': 'id.co.bankbkemobile.digitalbank'},
    {
      'label': 'OCTO by CIMB Niaga',
      'packageName': 'id.co.cimbniaga.mobile.android',
    },
    {'label': 'OCBC mobile', 'packageName': 'com.ocbcnisp.onemobileapp'},
    {'label': 'bale by BTN', 'packageName': 'id.co.btn.mobilebanking.android'},
    {'label': 'Permata ME', 'packageName': 'net.myinfosys.PermataMobileX'},
    {'label': 'Jenius', 'packageName': 'com.btpn.dc'},
    {'label': 'DBS digibank', 'packageName': 'com.dbs.id.pt.digitalbank'},
  ];

  static const wallets = <Map<String, String>>[
    {'label': 'GoPay', 'packageName': 'com.gojek.gopay'},
    {'label': 'ShopeePay', 'packageName': 'com.shopeepay.id'},
    {'label': 'DANA', 'packageName': 'id.dana'},
    {'label': 'OVO', 'packageName': 'ovo.id'},
    {'label': 'LinkAja', 'packageName': 'com.telkom.mwallet'},
    {'label': 'AstraPay', 'packageName': 'com.ada.astrapay'},
    {'label': 'i.saku', 'packageName': 'com.isaku.app'},
  ];

  static List<Map<String, dynamic>> get all => [
    ...banks.map((source) => {...source, 'sourceType': 'Bank'}),
    ...wallets.map((source) => {...source, 'sourceType': 'E-wallet'}),
  ];
}
