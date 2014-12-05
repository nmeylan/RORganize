/**
 * User: nmeylan
 * Date: 04.12.14
 * Time: 18:14
 */
$.ui.sortable.prototype.refreshPositions = function(fast) {
    //This has to be redone because due to the item being moved out/into the offsetParent, the offsetParent's position will change
    if(this.offsetParent && this.helper) {
        this.offset.parent = this._getParentOffset();
    }

    for (var i = this.items.length - 1; i >= 0; i--){
        var item = this.items[i];

        //We ignore calculating positions of all connected containers when we're not over them
        if(item.instance != this.currentContainer && this.currentContainer && item.item[0] != this.currentItem[0])
            continue;

        var t = this.options.toleranceElement ? $(this.options.toleranceElement, item.item) : item.item;

        if (!fast) {
            /********** MODIFICATION ***********/

            if(item.item.css('display') === 'none') {
                item.width = 0;
                item.height = 0;
            } else {
                item.width = t.outerWidth();
                item.height = t.outerHeight();
            }

            /********** END MODIFICATION ***********/
        }

        var p = t.offset();
        item.left = p.left;
        item.top = p.top;
    };

    if(this.options.custom && this.options.custom.refreshContainers) {
        this.options.custom.refreshContainers.call(this);
    } else {
        for (var i = this.containers.length - 1; i >= 0; i--){

            /********** MODIFICATION ***********/

            if (this.containers[i].element.css('display') == 'none') {
                this.containers[i].containerCache.left = 0;
                this.containers[i].containerCache.top = 0;
                this.containers[i].containerCache.width = 0;
                this.containers[i].containerCache.height = 0;
            } else {
                var p = this.containers[i].element.offset();
                this.containers[i].containerCache.left = p.left;
                this.containers[i].containerCache.top = p.top;
                this.containers[i].containerCache.width = this.containers[i].element.outerWidth();
                this.containers[i].containerCache.height = this.containers[i].element.outerHeight();
            }

            /********** END MODIFICATION ***********/
        };
    }

    return this;
};