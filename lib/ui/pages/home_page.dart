import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_x_todo/controllers/task_controller.dart';
import 'package:get_x_todo/models/task.dart';
import 'package:get_x_todo/services/theme_services.dart';
import 'package:get_x_todo/ui/pages/add_task_page.dart';
import 'package:get_x_todo/ui/size_config.dart';
import 'package:get_x_todo/ui/widgets/button.dart';
import 'package:get_x_todo/ui/widgets/task_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/notification_services.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    // _taskController.getTasks();
  }

  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(
            height: 6,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  AppBar _appBar(con) {
    return AppBar(
      backgroundColor: context.theme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          ThemeServices().swichTheme();
        },
        icon: Icon(
          Get.isDarkMode
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round_outlined,
          size: 24,
          color: primaryClr,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            notifyHelper.cancelAllNotification();
            _taskController.deletAllTasks();
          },
          icon: Icon(
            Icons.cleaning_services_outlined,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        CircleAvatar(
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.yMMMMd().format(DateTime.now()),
                  style: subheadingStyel),
              Text("Today", style: subheadingStyel),
            ],
          ),
          MyButton(
              label: '+ Add Task',
              onTap: () async {
                await Get.to(AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: EdgeInsets.only(top: 6, left: 20),
      child: DatePicker(
        DateTime.now(),
        width: 80,
        height: 100,
        initialSelectedDate: DateTime.now(),
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white60 : Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        )),
        monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white60 : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        )),
        dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    _taskController.getTasks();
  }

  _showTasks() {
    return Expanded(
      child: Obx(
        () {
          if (_taskController.taskList.isEmpty) {
            return _noTaskMsg();
          } else {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(),
              child: ListView.builder(
                scrollDirection: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  var task = _taskController.taskList[index];
                  if (task.repeat == 'Daily' ||
                      task.date == DateFormat.yMEd().format(_selectedDate) ||
                      (task.repeat == 'Weekly' &&
                          _selectedDate
                                      .difference(
                                          DateFormat.yMEd().parse(task.date!))
                                      .inDays %
                                  7 ==
                              0) ||
                      (task.repeat == 'Monthly' &&
                          DateFormat.yMEd().parse(task.date!).day ==
                              _selectedDate.day)) {
                    // var hour = task.startTime.toString().split(':')[0];
                    // var minuts = task.startTime.toString().split(':')[1];
                    var date = DateFormat.jm().parse(task.startTime!);
                    var myTime = DateFormat('HH:mm:s').format(date);
                    notifyHelper.scheduledNotification(
                        int.parse(task.startTime.toString().split(':')[0]),
                        int.parse(task.startTime.toString().split(':')[1]),
                        task);
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 1375),
                      child: SlideAnimation(
                        horizontalOffset: 300,
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () => ShowBottomSheet(context, task),
                            child: Expanded(
                              child: TaskTile(task),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else
                    return Container();
                },
                itemCount: _taskController.taskList.length,
              ),
            );
          }
        },
      ),
    );
  }

  _noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 2),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(
                          height: 220,
                        ),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    semanticsLabel: 'Task',
                    color: primaryClr.withOpacity(0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 10,
                    ),
                    child: Text(
                      'You do not have any tasks yet! \n Add new tasks to make your days productive',
                      style: subTitelStyel,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // SizeConfig.orientation == Orientation.landscape
                  //     ? const SizedBox(
                  //         height: 120,
                  //       )
                  //     : const SizedBox(
                  //         height: 180,
                  //       ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  ShowBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.only(top: 4),
            width: SizeConfig.screenWidth,
            height: (SizeConfig.orientation == Orientation.landscape)
                ? (task.isCompleted == 1
                    ? SizeConfig.screenHeight * 0.6
                    : SizeConfig.screenHeight * 0.8)
                : (task.isCompleted == 1
                    ? SizeConfig.screenHeight * 0.30
                    : SizeConfig.screenHeight * 0.39),
            color: Get.isDarkMode ? darkHeaderClr : Colors.white,
            child: Column(
              children: [
                Flexible(
                  child: Container(
                    height: 6,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Get.isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[300]),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                task.isCompleted == 1
                    ? Container()
                    : _buildBottomSheet(
                        label: 'Task Completed',
                        onTap: () {
                          _taskController.markTaskCompleted(task.id!);
                          Get.back();
                        },
                        clr: primaryClr),
                _buildBottomSheet(
                    label: 'delete Task ',
                    onTap: () {
                      notifyHelper.cancelNotification(task);
                      _taskController.deletTasks(task);
                      Get.back();
                    },
                    clr: Colors.red[300]!),
                Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr),
                _buildBottomSheet(
                    label: 'Cancel  ',
                    onTap: () {
                      Get.back();
                    },
                    clr: primaryClr),
                const SizedBox(
                  height: 20,
                ),
              ],
            )),
      ),
    );
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
            child: Text(
          label,
          style:
              isClose ? titelStyel : titelStyel.copyWith(color: Colors.white),
        )),
      ),
    );
  }
}
