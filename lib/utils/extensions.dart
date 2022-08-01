extension DateFormat on DateTime{
  String toStringMonth(){
    switch(month){
      case 1 : return "Ene";
      case 2 : return "Feb";
      case 3 : return "Mar";
      case 4 : return "Abr";
      case 5 : return "May";
      case 6 : return "Jun";
      case 7 : return "Jul";
      case 8 : return "Ago";
      case 9 : return "Sep";
      case 10 : return "Oct";
      case 11 : return "Nov";
      case 12 : return "Dic";
      default : return "";
    }
  }
  String toStringWeekDay(){
    switch(weekday){
      case 1 : return "Lun";
      case 2 : return "Mar";
      case 3 : return "Mie";
      case 4 : return "Jue";
      case 5 : return "Vie";
      case 6 : return "Sab";
      case 7 : return "Dom";
      default : return "";
    }
  }
  String iDay(){
    String dayValue = day.toString();
    if(dayValue.length == 1){
      dayValue = '0$day';
    }
    return '$dayValue-$month-$year';
  }
  DateTime lastMonday(){
    DateTime res = this;
    while(res.weekday!=1){
      res= res.add(Duration(days: -1));
    }
    return res;
  }
  bool isSameDate(DateTime date){
    return day == date.day && month == date.month && year == date.year;
  }
  int fromBirthdayToAge(){
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - year;
    int month1 = currentDate.month;
    int month2 = month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}

extension StringFormat on String{

  String maxLength(int num){
    if(length>num){
      return substring(0, num);
    }
    return this;
  }
}