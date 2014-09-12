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

var MONTHS = ['Jan', 'Feb', 'Mar', 'Avr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
function roadmap_gantt() {
    bind_gantt_filter();
    bind_save_button();
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
                        {unit: "week", step: 1, date: "%W" }
                    ];
                    gantt.config.scale_height = 50;
                    gantt.config.scale_width = 50;
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

        gantt.min_column_width = 50;
        gantt.templates.task_cell_class = function (task, date) {
            var classes = "";
            if ((date.getDay() == 0 || date.getDay() == 6) && scale_config !== "4") // if out from working days and scale is not years.
                classes = "week_end ";
            classes += task.context.type;
            return classes;
        };

        gantt.templates.task_class = function (start, end, task) {
            var classes = "";
            classes += task.context.type;
            if (!task.context.are_data_provided) {
                classes += " phantom_task";
            }
            return classes;
        };


        var edition = $('#gantt_mode').val() === 'edition';

        gantt.config.drag_progress = false;
        gantt.config.drag_move = edition;
        gantt.config.drag_resize = edition;
        gantt.config.drag_links = edition;
        gantt.config.autosize = true;

        config_column(edition);

        gantt.templates.rightside_text = function (start, end, task) {
            var assigne = task.context.assigne;
            return assigne !== undefined ? '<b>' + assigne !== null ? assigne : 'unassigned' + '</b>' : '';
        };

        gantt.templates.leftside_text = function (start, end, task) {
            var duration = "<span>"+task.context.start_date_str + " <b>-</b> " + task.context.due_date_str+"</span>";
            var progress = task.progress !== undefined ? "<span style='text-align:right;'>" + Math.round(task.progress * 100) + "% </span>" : '';
            return duration + progress;
        };

        gantt.attachEvent("onBeforeLightbox", function (id) {
            return false;
        });
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


        function limitMoveLeft(task, limit) {
            var dur = task.end_date - task.start_date;
            task.end_date = new Date(limit.end_date);
            task.start_date = new Date(+task.end_date - dur);
        }

        function limitMoveRight(task, limit) {
            var dur = task.end_date - task.start_date;
            task.start_date = new Date(limit.start_date);
            task.end_date = new Date(+task.start_date + dur);
        }

        function limitResizeLeft(task, limit) {
            task.end_date = new Date(limit.end_date);
        }

        function limitResizeRight(task, limit) {
            task.start_date = new Date(limit.start_date)
        }

        gantt.attachEvent("onTaskClick", function(id,e){
            return !$(e.target).hasClass('update_task');
        });

        gantt.attachEvent("onTaskDrag", function (id, mode, task, original, e) {
            var parent = task.parent ? gantt.getTask(task.parent) : null,
                children = gantt.getChildren(id),
                modes = gantt.config.drag_mode;

            var limitLeft = null,
                limitRight = null;

            if (!(mode == modes.move || mode == modes.resize)) return;

            if (mode == modes.move) {
                limitLeft = limitMoveLeft;
                limitRight = limitMoveRight;
            } else if (mode == modes.resize) {
                limitLeft = limitResizeLeft;
                limitRight = limitResizeRight;
            }

            //check parents constraints
            if (parent && +parent.end_date < +task.end_date) {
                limitLeft(task, parent);
            }
            if (parent && +parent.start_date > +task.start_date) {
                limitRight(task, parent);
            }
            if (!(mode == modes.move || mode == modes.resize)) return;
            task.context.due_date = task.end_date;
            task.context.due_date_str = task.context.due_date.getDate() + ' ' + MONTHS[task.context.due_date.getMonth()] + '.';
            task.context.start_date_str = task.start_date.getDate() + ' ' + MONTHS[task.start_date.getMonth()] + '.';
            gantt.refreshTask(task.id);

        });
        gantt._fix_dnd_scale_time = __fix_dnd_scale_time = function (t, e) {
            var n = 'day', i = 1;
            gantt.config.round_dnd_dates || (n = "minute", i = gantt.config.time_step), e.mode == gantt.config.drag_mode.resize ? e.left ? t.start_date = gantt._get_closest_date({date: t.start_date, unit: n, step: i}) : t.end_date = gantt._get_closest_date({date: t.end_date, unit: n, step: i}) : e.mode == gantt.config.drag_mode.move && (t.start_date = gantt._get_closest_date({date: t.start_date, unit: n, step: i}), t.end_date = gantt.calculateEndDate(t.start_date, t.duration, gantt.config.duration_unit));
            return t;
        };

        gantt.attachEvent("onAfterTaskDrag", function (id, mode, e) {
            var drag = gantt._tasks_dnd.drag;
            var task = gantt.getTask(id);
            var children = gantt.getChildren(id);
            __fix_dnd_scale_time(task, drag);
            task.context.due_date = task.end_date;
            task.context.due_date_str = task.context.due_date.getDate() + ' ' + MONTHS[task.context.due_date.getMonth()] + '.';
            task.context.start_date_str = task.start_date.getDate() + ' ' + MONTHS[task.start_date.getMonth()] + '.';
            gantt.refreshTask(task.id);
            for (var i = 0; i < children.length; i++) {
                var child = gantt.getTask(children[i]);
                dnd_apply_constraints(mode, drag, task, child);
                __fix_dnd_scale_time(child, drag);
            }
        });

    }
}

function dnd_apply_constraints(mode, drag, task, child) {
    var modes = gantt.config.drag_mode;
    if (mode == modes.resize) {
        if (+task.end_date < +child.end_date) {
            diff = drag.obj.duration - task.duration;
            if (+task.start_date != +child.start_date && diff > 0) {
                diff = drag.obj.duration - task.duration;
                child.start_date.setDate(child.start_date.getDate() - diff);
                if (+task.start_date > +child.start_date) {
                    child.start_date = task.start_date;
                }
            }
            child.end_date = task.end_date;
            child.hasChanged = true;
        } else if (+task.start_date > +child.start_date) {
            diff = drag.obj.duration - task.duration;
            if (+task.end_date != +child.end_date && diff > 0) {
                diff = drag.obj.duration - task.duration;
                child.end_date.setDate(child.end_date.getDate() + diff);
                if (+task.end_date < +child.end_date) {
                    child.end_date = task.end_date;
                }
            }
            child.start_date = task.start_date;
            child.hasChanged = true;
        }
    } else if (mode == modes.move) {
        if (+task.end_date < +child.end_date) {
            diff = gantt.calculateDuration(task.end_date, child.end_date);
            child.start_date.setDate(child.start_date.getDate() - diff);
            child.end_date = task.end_date;
        } else if (+task.start_date > +child.start_date) {
            diff = gantt.calculateDuration(child.start_date, task.start_date);
            child.end_date.setDate(child.end_date.getDate() + diff);
            child.start_date = task.start_date;
        }
    }
    child.context.due_date = child.end_date;
    child.context.due_date_str = child.context.due_date.getDate() + ' ' + MONTHS[child.context.due_date.getMonth()] + '.';
    child.context.start_date_str = child.start_date.getDate() + ' ' + MONTHS[child.start_date.getMonth()] + '.';
    child.duration = gantt.calculateDuration(child.start_date, child.end_date);
    gantt.refreshTask(child.id);
}

function merge_gantt_data(json) {
    var old_data = gantt.json.serialize();
    var json = JSON.parse(json);
    var new_data = json.data;
    var tmp_old = old_data.data;
    for (var i = 0; i < new_data.length; i++) {
        for (var j = 0; j < tmp_old.length; j++) {
            if (new_data[i].id === tmp_old[j].id) {
                new_data[i] = tmp_old[j];
            }
        }
    }
    return json;
}

function bind_gantt_filter() {
    var select = $("#gantt_version_select");
    select.change(function (e) {
        e.preventDefault();
        jQuery.ajax({
            url: select.data("link"),
            type: 'get',
            dataType: 'script',
            data: {value: select.val(), mode: $('#gantt_mode').val()}
        });
    });
}

function bind_save_button(){
    $('#save_gantt').click(function(e){
        e.preventDefault();
        var el = $(this);
        var form = el.parents('form');
        var updated_tasks = $('input.update_task:checked');
        var ids = [];
        var serialized_gantt = gantt.json.serialize();
        var data = [];
        for(var i = 0; i < updated_tasks.length; i++){
           ids.push($(updated_tasks[i]).val());
        }
        if(ids.length == 0){
            apprise('Before saving please select which elements you want to save.');
        }else {

            console.log(serialized_gantt);
            var len = serialized_gantt.data.length;
            for (var i = 0; i < len; i++) {
                if (ids.indexOf(serialized_gantt.data[i].id.toString()) != -1) {
                    data.push(serialized_gantt.data[i]);
                } else if (ids.indexOf(serialized_gantt.data[i].parent.toString()) != -1) {

                    data.push(serialized_gantt.data[i]);
                }
            }
            serialized_gantt.data = data;
            console.log(serialized_gantt);
            $.ajax({
                url: form.attr('action'),
                type: form.attr('method'),
                dataType: 'script',
                data: {gantt: serialized_gantt}
            });
        }
    })
}

function config_column(edition){
    var edit_tasks;
    edit_tasks = edition ? {name: "update", label: "<span class='octicon octicon-pencil'></span>", align: "center", width: 10,
        template: function (item) {
            return "<input type='checkbox' name='update_task[]' class='update_task' value='"+item.id+"'>";
        }
    } : {name : '', label: '', width: 0, template : function(item){return ''}};
    gantt.config.columns = [
        {name: "text", label: "Task name", tree: true, width: 100,
            template: function (item) {
                var context = item.context;
                if (context.type === "issue") {
                    return context.link
                } else {
                    return item.text
                }
            }
        },
        {name: "start_date", label: "Start date", width: 60, align: "center",
            template: function (item) {
                return item.start_date;
            }
        },
        {name: "due_date", label: "Due date", width: 60, align: "center",
            template: function (item) {
                return item.context.due_date;
            }
        },
        {name: "duration", label: "Duration", align: "center", width: 40,
            template: function (item) {
                return item.duration;
            }
        },
        edit_tasks
    ];

}