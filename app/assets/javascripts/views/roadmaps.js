/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 15:52
 */
function on_load_roadmap_scripts() {
    roadmap_index();
    roadmap_calendar();
    roadmap_gantt();
}

function roadmap_index() {
    multi_toogle(".toggle");
}

function roadmap_calendar() {
    bind_calendar_button();
}

function roadmap_gantt() {

    ajax_trigger("#gantt_version_select", 'change', 'get');
    if (gon.Gantt_JSON) {
        var scale_config = "3";

        function setScaleConfig(value) {
            var weekScaleTemplate = function (date) {
                var dateToStr = gantt.date.date_to_str("%d %M, %Y");
                var endDate = gantt.date.add(gantt.date.add(date, 1, "week"), -1, "day");
                return dateToStr(date) + " - " + dateToStr(endDate);
            };
            var monthScaleTemplate = function (date) {
                var dateToStr = gantt.date.date_to_str("%M");
                var endDate = gantt.date.add(date, 2, "month");
                return dateToStr(date) + " - " + dateToStr(endDate);
            };
            switch (value) {
                case "1":
                    gantt.config.scale_unit = "day";
                    gantt.config.step = 1;
                    gantt.config.date_scale = "%D. %d %M";
                    gantt.config.subscales = [];
                    gantt.config.scale_height = 27;
                    gantt.templates.date_scale = null;
                    break;
                case "2":
                    gantt.config.scale_unit = "week";
                    gantt.config.step = 1;
                    gantt.templates.date_scale = weekScaleTemplate;
                    gantt.config.subscales = [
                        {unit: "day", step: 1, date: "%D. %d" }
                    ];
                    gantt.config.scale_height = 50;
                    break;
                case "3":
                    gantt.config.scale_unit = "month";
                    gantt.config.date_scale = "%F, %Y";
                    gantt.config.subscales = [
                        {unit: "day", step: 4, date: "%D. %d" }
                    ];
                    gantt.config.scale_height = 50;
                    gantt.templates.date_scale = null;
                    break;
                case "4":
                    gantt.config.scale_unit = "year";
                    gantt.config.step = 1;
                    gantt.config.date_scale = "%Y";
                    gantt.config.min_column_width = 50;

                    gantt.config.scale_height = 90;
                    gantt.templates.date_scale = null;


                    gantt.config.subscales = [
                        {unit: "month", step: 3, template: monthScaleTemplate},
                        {unit: "month", step: 1, date: "%M" }
                    ];
                    break;
            }
        }

//
//        gantt.config.work_time = true;
//
//
//        gantt.config.scale_unit = "day";
//        gantt.config.date_scale = "%D, %d";
//        gantt.config.min_column_width = 60;
//        gantt.config.duration_unit = "day";
//        gantt.config.scale_height = 20*3;
//        gantt.config.row_height = 30;

        gantt.templates.task_cell_class = function (task, date) {
            var classes = "";
            if ((date.getDay() == 0 || date.getDay() == 6) && scale_config !== "4") // if out from working days and scale is not years.
                classes = "week_end ";
            classes += task.context.type;
            return classes;
        };

        gantt.templates.task_class  = function(start, end, task){
            var classes = "";
            classes += task.context.type;
            return classes;
        };


        gantt.attachEvent("onBeforeLightbox", function (id) {
            return false;
        });
        gantt.config.columns = [
            {name: "text", label: "Task name", tree: true, width: '*',
                template: function (item) {
                    var context = item.context;
                    if (context.type === "issue") {
                        return context.link
                    } else {
                        return item.text
                    }
                }
            },
            {name: "start_date", label: "Start date", width: 80, align: "center",
                template: function (item) {
                    return item.start_date;
                }
            },
            {name: "due_date", label: "Due date", width: 80, align: "center",
                template: function (item) {
                    return item.context.due_date;
                }
            },
            {name: "duration", label: "Duration", align: "center", width: 100,
                template: function (item) {
                    return item.duration;
                }
            }
        ];
        gantt.templates.rightside_text = function (start, end, task) {
            var assigne = task.context.assigne;
            return assigne !== undefined ? '<b>' + assigne + '</b>' : '';
        };

        gantt.templates.leftside_text = function (start, end, task) {

            return scale_config === "2" ? task.duration + " days" : task.context.start_date_str + " <b>-</b> " + task.context.due_date_str;
        };

        gantt.templates.progress_text = function (start, end, task) {
            return "<span style='text-align:left;'>" + Math.round(task.progress * 100) + "% </span>";
        };

        gantt.config.drag_progress = false;
        gantt.config.drag_move = false;
        gantt.config.drag_resize = false;
        gantt.config.drag_links = false;
        setScaleConfig(scale_config);
        gantt.init('gantt_chart');

        gantt.parse(gon.Gantt_JSON, 'json');

        var func = function (e) {
            e = e || window.event;
            var el = e.target || e.srcElement;
            scale_config = el.value;
            setScaleConfig(scale_config);
            gantt.render();
        };

        var els = document.getElementsByName("scale");
        for (var i = 0; i < els.length; i++) {
            els[i].onclick = func;
        }

    }
}
