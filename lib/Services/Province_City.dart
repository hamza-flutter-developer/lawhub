import 'package:http/http.dart' as http;
import 'package:lawhub/model/Province_City.dart';

var link = "https://raw.githubusercontent.com/HassanAhmad5/Pakistan_Provinces_Cities_API/main/pak_provinces_cities.json";


getData() async {
  var res = await http.get(Uri.parse(link));

  if(res.statusCode == 200){
    Temperatures data = temperaturesFromJson(res.body);
    return data;
  }
}