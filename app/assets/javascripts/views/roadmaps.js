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
    if (gon.Gantt_XML) {
        var gantt = new GanttChart();
        gantt.setImagePath("/assets/gantt/");
        gantt.showTreePanel(true);
        gantt.showDescTask(true, 'n,e,d');
        gantt.create("gantt_chart");
        gantt.loadData(new String(gon.Gantt_XML), false, true);
    }
}