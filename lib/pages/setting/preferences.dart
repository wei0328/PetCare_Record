import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petcare_record/globalclass/color.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  double height = 0.00;
  double width = 0.00;

  String selectedDateFormat = 'Month / Day / Year';
  String selectedLength = 'cm';
  String selectedWeight = 'kg';
  String selectedTemp = '°C';

  List<String> dateFormatItem = [
    'Month / Day / Year',
    'Day / Month / Year',
    'Year / Month / Day'
  ];
  List<String> lengthItem = ['cm', 'in'];
  List<String> weightItem = ['kg', 'lb'];
  List<String> tempItem = ['°C', '°F'];

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDateFormat =
          prefs.getString('selectedDateFormat') ?? 'Month / Day / Year';
      selectedLength = prefs.getString('selectedLength') ?? 'cm';
      selectedWeight = prefs.getString('selectedWeight') ?? 'kg';
      selectedTemp = prefs.getString('selectedTemp') ?? '°C';
    });
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDateFormat', selectedDateFormat);
    await prefs.setString('selectedLength', selectedLength);
    await prefs.setString('selectedWeight', selectedWeight);
    await prefs.setString('selectedTemp', selectedTemp);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width / 15,
          vertical: height / 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / 56),
            buildDropdown(
              context,
              'Date Format',
              selectedDateFormat,
              dateFormatItem,
              Icons.calendar_month,
              (value) {
                setState(() {
                  selectedDateFormat = value!;
                });
              },
            ),
            SizedBox(height: height / 56),
            buildDropdown(
              context,
              'Length Unit',
              selectedLength,
              lengthItem,
              Icons.straighten,
              (value) {
                setState(() {
                  selectedLength = value!;
                });
              },
            ),
            SizedBox(height: height / 56),
            buildDropdown(
              context,
              'Weight Unit',
              selectedWeight,
              weightItem,
              Icons.monitor_weight_outlined,
              (value) {
                setState(() {
                  selectedWeight = value!;
                });
              },
            ),
            SizedBox(height: height / 56),
            buildDropdown(
              context,
              'Temperature Unit',
              selectedTemp,
              tempItem,
              Icons.thermostat_outlined,
              (value) {
                setState(() {
                  selectedTemp = value!;
                });
              },
            ),
            SizedBox(height: height / 28),
            InkWell(
              onTap: () async {
                await savePreferences();
              },
              child: Center(
                child: Container(
                  height: 40.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: PetRecordColor.theme,
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(
    BuildContext context,
    String label,
    String selectedItem,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Center(
          child: Container(
            width: width,
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PetRecordColor.lightgrey,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: PetRecordColor.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: Icon(icon, color: PetRecordColor.theme),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                selectedItemBuilder: (BuildContext context) {
                  return items.map((String value) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
