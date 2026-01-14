class FirebaseBasicData {

  Object classDataTable() {
    return {
      "7_1": {
        "name": "سابع 1",
        "grade": "7",
        "class": "1",
        "students": ["s001", "s002", "s003", "s004", "s005"],
        "exit": 1,
      },
      /*"7_2": {
      "name": "سابع 2",
      "grade": "7",
      "class": "2",
      "students": ["s003"],
      "exit": 2,
    },
    "8_1": {
      "name": "ثامن 1",
      "grade": "8",
      "class": "1",
      "students": ["s004"],
      "exit": 3,
    },*/
      "8_2": {
        "name": "ثامن 2",
        "grade": "8",
        "class": "2",
        "students": ["s006", "s007", "s008"],
        "exit": 4,
      },
    };
  }

  Object exitsDataTable(){
    return {
      "7_1": {"exit": 1},
      "7_2": {"exit": 2},
      "8_1": {"exit": 3},
      "8_2": {"exit": 4},
    };
  }

  Object evacuationsTable(){
    return {
      "7_1": {"absent": {}, "present": {}},
      "7_2": {"absent": {}, "present": {}},
      "8_1": {"absent": {}, "present": {}},
      "8_2": {"absent": {}, "present": {}},
    };
  }

  Object studentDataTable(){
    return {
      "s001": {
        "name": "سارة محمد",
        "grade": "7",
        "class": "1",
        "classKey": "7_1",
        "qr": "s001",
      },
      "s002": {
        "name": "ريم خالد",
        "grade": "7",
        "class": "1",
        "classKey": "7_1",
        "qr": "s002",
      },
      "s003": {
        "name": "نور أحمد",
        "grade": "7",
        "class": "1",
        "classKey": "7_1",
        "qr": "s003",
      },
      "s004": {
        "name": "جنى علي",
        "grade": "7",
        "class": "1",
        "classKey": "7_1",
        "qr": "s004",
      },
      "s005": {
        "name": "شهد حسين",
        "grade": "7",
        "class": "1",
        "classKey": "7_1",
        "qr": "s005",
      },
      "s006": {
        "name": "دعاء جاد",
        "grade": "8",
        "class": "2",
        "classKey": "8_2",
        "qr": "s006",
      },
      "s007": {
        "name": "سارة علي",
        "grade": "8",
        "class": "2",
        "classKey": "8_2",
        "qr": "s007",
      },
      "s008": {
        "name": "مريم خالد",
        "grade": "8",
        "class": "2",
        "classKey": "8_2",
        "qr": "s008",
      },
    };
  }

  String getCurrentDate(){
    DateTime now = DateTime.now();
    String today = DateTime.now().toString().split(' ')[0];
    String formattedDate =
        "${now.day}-${now.month}-${now.year}";
    return today;
  }
}
