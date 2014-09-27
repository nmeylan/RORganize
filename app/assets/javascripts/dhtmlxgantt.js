function dtmlXMLLoaderObject(e, t, n, r) {
    return this.xmlDoc = "", this.async = "undefined" != typeof n ? n : !0, this.onloadAction = e || null, this.mainObject = t || null, this.waitCall = null, this.rSeed = r || !1, this
}
function callerFunction(e, t) {
    return this.handler = function (n) {
        return n || (n = window.event), e(n, t), !0
    }, this.handler
}
function getAbsoluteLeft(e) {
    return getOffset(e).left
}
function getAbsoluteTop(e) {
    return getOffset(e).top
}
function getOffsetSum(e) {
    for (var t = 0, n = 0; e;)t += parseInt(e.offsetTop), n += parseInt(e.offsetLeft), e = e.offsetParent;
    return{top: t, left: n}
}
function getOffsetRect(e) {
    var t = e.getBoundingClientRect(), n = document.body, r = document.documentElement, i = window.pageYOffset || r.scrollTop || n.scrollTop, s = window.pageXOffset || r.scrollLeft || n.scrollLeft, o = r.clientTop || n.clientTop || 0, u = r.clientLeft || n.clientLeft || 0, a = t.top + i - o, f = t.left + s - u;
    return{top: Math.round(a), left: Math.round(f)}
}
function getOffset(e) {
    return e.getBoundingClientRect ? getOffsetRect(e) : getOffsetSum(e)
}
function convertStringToBoolean(e) {
    switch ("string" == typeof e && (e = e.toLowerCase()), e) {
        case"1":
        case"true":
        case"yes":
        case"y":
        case 1:
        case!0:
            return!0;
        default:
            return!1
    }
}
function getUrlSymbol(e) {
    return-1 != e.indexOf("?") ? "&" : "?"
}
function dhtmlDragAndDropObject() {
    return window.dhtmlDragAndDrop ? window.dhtmlDragAndDrop : (this.lastLanding = 0, this.dragNode = 0, this.dragStartNode = 0, this.dragStartObject = 0, this.tempDOMU = null, this.tempDOMM = null, this.waitDrag = 0, window.dhtmlDragAndDrop = this, this)
}
function _dhtmlxError() {
    return this.catches || (this.catches = []), this
}
function dhtmlXHeir(e, t) {
    for (var n in t)"function" == typeof t[n] && (e[n] = t[n]);
    return e
}
function dhtmlxEvent(e, t, n) {
    e.addEventListener ? e.addEventListener(t, n, !1) : e.attachEvent && e.attachEvent("on" + t, n)
}
function dhtmlxDetachEvent(e, t, n) {
    e.removeEventListener ? e.removeEventListener(t, n, !1) : e.detachEvent && e.detachEvent("on" + t, n)
}
function dhtmlxDnD(e, t) {
    t && (this._settings = t), dhtmlxEventable(this), dhtmlxEvent(e, "mousedown", dhtmlx.bind(function (t) {
        this.dragStart(e, t)
    }, this))
}
function dataProcessor(e) {
    return this.serverProcessor = e, this.action_param = "!nativeeditor_status", this.object = null, this.updatedRows = [], this.autoUpdate = !0, this.updateMode = "cell", this._tMode = "GET", this.post_delim = "_", this._waitMode = 0, this._in_progress = {}, this._invalid = {}, this.mandatoryFields = [], this.messages = [], this.styles = {updated: "font-weight:bold;", inserted: "font-weight:bold;", deleted: "text-decoration : line-through;", invalid: "background-color:FFE0E0;", invalid_cell: "border-bottom:2px solid red;", error: "color:red;", clear: "font-weight:normal;text-decoration:none;"}, this.enableUTFencoding(!0), dhtmlxEventable(this), this
}
window.dhtmlx || (dhtmlx = function (e) {
    for (var t in e)dhtmlx[t] = e[t];
    return dhtmlx
}), dhtmlx.extend_api = function (e, t, n) {
    var r = window[e];
    r && (window[e] = function (e) {
        var n;
        if (e && "object" == typeof e && !e.tagName) {
            n = r.apply(this, t._init ? t._init(e) : arguments);
            for (var s in dhtmlx)t[s] && this[t[s]](dhtmlx[s]);
            for (var s in e)t[s] ? this[t[s]](e[s]) : 0 === s.indexOf("on") && this.attachEvent(s, e[s])
        } else n = r.apply(this, arguments);
        return t._patch && t._patch(this), n || this
    }, window[e].prototype = r.prototype, n && dhtmlXHeir(window[e].prototype, n))
}, dhtmlxAjax = {get: function (e, t) {
    var n = new dtmlXMLLoaderObject(!0);
    return n.async = arguments.length < 3, n.waitCall = t, n.loadXML(e), n
}, post: function (e, t, n) {
    var r = new dtmlXMLLoaderObject(!0);
    return r.async = arguments.length < 4, r.waitCall = n, r.loadXML(e, !0, t), r
}, getSync: function (e) {
    return this.get(e, null, !0)
}, postSync: function (e, t) {
    return this.post(e, t, null, !0)
}}, dtmlXMLLoaderObject.count = 0, dtmlXMLLoaderObject.prototype.waitLoadFunction = function (e) {
    var t = !0;
    return this.check = function () {
        if (e && e.onloadAction && (!e.xmlDoc.readyState || 4 == e.xmlDoc.readyState)) {
            if (!t)return;
            t = !1, dtmlXMLLoaderObject.count++, "function" == typeof e.onloadAction && e.onloadAction(e.mainObject, null, null, null, e), e.waitCall && (e.waitCall.call(this, e), e.waitCall = null)
        }
    }, this.check
}, dtmlXMLLoaderObject.prototype.getXMLTopNode = function (e, t) {
    var n;
    if (this.xmlDoc.responseXML) {
        var r = this.xmlDoc.responseXML.getElementsByTagName(e);
        if (0 === r.length && -1 != e.indexOf(":"))var r = this.xmlDoc.responseXML.getElementsByTagName(e.split(":")[1]);
        n = r[0]
    } else n = this.xmlDoc.documentElement;
    if (n)return this._retry = !1, n;
    if (!this._retry && _isIE) {
        this._retry = !0;
        var t = this.xmlDoc;
        return this.loadXMLString(this.xmlDoc.responseText.replace(/^[\s]+/, ""), !0), this.getXMLTopNode(e, t)
    }
    return dhtmlxError.throwError("LoadXML", "Incorrect XML", [t || this.xmlDoc, this.mainObject]), document.createElement("DIV")
}, dtmlXMLLoaderObject.prototype.loadXMLString = function (e, t) {
    if (_isIE)this.xmlDoc = new ActiveXObject("Microsoft.XMLDOM"), this.xmlDoc.async = this.async, this.xmlDoc.onreadystatechange = function () {
    }, this.xmlDoc.loadXML(e); else {
        var n = new DOMParser;
        this.xmlDoc = n.parseFromString(e, "text/xml")
    }
    t || (this.onloadAction && this.onloadAction(this.mainObject, null, null, null, this), this.waitCall && (this.waitCall(), this.waitCall = null))
}, dtmlXMLLoaderObject.prototype.loadXML = function (e, t, n, r) {
    this.rSeed && (e += (-1 != e.indexOf("?") ? "&" : "?") + "a_dhx_rSeed=" + (new Date).valueOf()), this.filePath = e, this.xmlDoc = !_isIE && window.XMLHttpRequest ? new XMLHttpRequest : new ActiveXObject("Microsoft.XMLHTTP"), this.async && (this.xmlDoc.onreadystatechange = new this.waitLoadFunction(this)), this.xmlDoc.open(t ? "POST" : "GET", e, this.async), r ? (this.xmlDoc.setRequestHeader("User-Agent", "dhtmlxRPC v0.1 (" + navigator.userAgent + ")"), this.xmlDoc.setRequestHeader("Content-type", "text/xml")) : t && this.xmlDoc.setRequestHeader("Content-type", "application/x-www-form-urlencoded"), this.xmlDoc.setRequestHeader("X-Requested-With", "XMLHttpRequest"), this.xmlDoc.send(null || n), this.async || (new this.waitLoadFunction(this))()
}, dtmlXMLLoaderObject.prototype.destructor = function () {
    return this._filterXPath = null, this._getAllNamedChilds = null, this._retry = null, this.async = null, this.rSeed = null, this.filePath = null, this.onloadAction = null, this.mainObject = null, this.xmlDoc = null, this.doXPath = null, this.doXPathOpera = null, this.doXSLTransToObject = null, this.doXSLTransToString = null, this.loadXML = null, this.loadXMLString = null, this.doSerialization = null, this.xmlNodeToJSON = null, this.getXMLTopNode = null, this.setXSLParamValue = null, null
}, dtmlXMLLoaderObject.prototype.xmlNodeToJSON = function (e) {
    for (var t = {}, n = 0; n < e.attributes.length; n++)t[e.attributes[n].name] = e.attributes[n].value;
    t._tagvalue = e.firstChild ? e.firstChild.nodeValue : "";
    for (var n = 0; n < e.childNodes.length; n++) {
        var r = e.childNodes[n].tagName;
        r && (t[r] || (t[r] = []), t[r].push(this.xmlNodeToJSON(e.childNodes[n])))
    }
    return t
}, dhtmlDragAndDropObject.prototype.removeDraggableItem = function (e) {
    e.onmousedown = null, e.dragStarter = null, e.dragLanding = null
}, dhtmlDragAndDropObject.prototype.addDraggableItem = function (e, t) {
    e.onmousedown = this.preCreateDragCopy, e.dragStarter = t, this.addDragLanding(e, t)
}, dhtmlDragAndDropObject.prototype.addDragLanding = function (e, t) {
    e.dragLanding = t
}, dhtmlDragAndDropObject.prototype.preCreateDragCopy = function (e) {
    return!e && !window.event || 2 != (e || event).button ? window.dhtmlDragAndDrop.waitDrag ? (window.dhtmlDragAndDrop.waitDrag = 0, document.body.onmouseup = window.dhtmlDragAndDrop.tempDOMU, document.body.onmousemove = window.dhtmlDragAndDrop.tempDOMM, !1) : (window.dhtmlDragAndDrop.dragNode && window.dhtmlDragAndDrop.stopDrag(e), window.dhtmlDragAndDrop.waitDrag = 1, window.dhtmlDragAndDrop.tempDOMU = document.body.onmouseup, window.dhtmlDragAndDrop.tempDOMM = document.body.onmousemove, window.dhtmlDragAndDrop.dragStartNode = this, window.dhtmlDragAndDrop.dragStartObject = this.dragStarter, document.body.onmouseup = window.dhtmlDragAndDrop.preCreateDragCopy, document.body.onmousemove = window.dhtmlDragAndDrop.callDrag, window.dhtmlDragAndDrop.downtime = (new Date).valueOf(), e && e.preventDefault ? (e.preventDefault(), !1) : !1) : void 0
}, dhtmlDragAndDropObject.prototype.callDrag = function (e) {
    e || (e = window.event);
    var t = window.dhtmlDragAndDrop;
    if (!((new Date).valueOf() - t.downtime < 100)) {
        if (!t.dragNode) {
            if (!t.waitDrag)return t.stopDrag(e, !0);
            if (t.dragNode = t.dragStartObject._createDragNode(t.dragStartNode, e), !t.dragNode)return t.stopDrag();
            t.dragNode.onselectstart = function () {
                return!1
            }, t.gldragNode = t.dragNode, document.body.appendChild(t.dragNode), document.body.onmouseup = t.stopDrag, t.waitDrag = 0, t.dragNode.pWindow = window, t.initFrameRoute()
        }
        if (t.dragNode.parentNode != window.document.body && t.gldragNode) {
            var n = t.gldragNode;
            t.gldragNode.old && (n = t.gldragNode.old), n.parentNode.removeChild(n);
            var r = t.dragNode.pWindow;
            if (n.pWindow && n.pWindow.dhtmlDragAndDrop.lastLanding && n.pWindow.dhtmlDragAndDrop.lastLanding.dragLanding._dragOut(n.pWindow.dhtmlDragAndDrop.lastLanding), _isIE) {
                var i = document.createElement("Div");
                i.innerHTML = t.dragNode.outerHTML, t.dragNode = i.childNodes[0]
            } else t.dragNode = t.dragNode.cloneNode(!0);
            t.dragNode.pWindow = window, t.gldragNode.old = t.dragNode, document.body.appendChild(t.dragNode), r.dhtmlDragAndDrop.dragNode = t.dragNode
        }
        t.dragNode.style.left = e.clientX + 15 + (t.fx ? -1 * t.fx : 0) + (document.body.scrollLeft || document.documentElement.scrollLeft) + "px", t.dragNode.style.top = e.clientY + 3 + (t.fy ? -1 * t.fy : 0) + (document.body.scrollTop || document.documentElement.scrollTop) + "px";
        var s;
        s = e.srcElement ? e.srcElement : e.target, t.checkLanding(s, e)
    }
}, dhtmlDragAndDropObject.prototype.calculateFramePosition = function (e) {
    if (window.name) {
        for (var t = parent.frames[window.name].frameElement.offsetParent, n = 0, r = 0; t;)n += t.offsetLeft, r += t.offsetTop, t = t.offsetParent;
        if (parent.dhtmlDragAndDrop) {
            var i = parent.dhtmlDragAndDrop.calculateFramePosition(1);
            n += 1 * i.split("_")[0], r += 1 * i.split("_")[1]
        }
        if (e)return n + "_" + r;
        this.fx = n, this.fy = r
    }
    return"0_0"
}, dhtmlDragAndDropObject.prototype.checkLanding = function (e, t) {
    e && e.dragLanding ? (this.lastLanding && this.lastLanding.dragLanding._dragOut(this.lastLanding), this.lastLanding = e, this.lastLanding = this.lastLanding.dragLanding._dragIn(this.lastLanding, this.dragStartNode, t.clientX, t.clientY, t), this.lastLanding_scr = _isIE ? t.srcElement : t.target) : e && "BODY" != e.tagName ? this.checkLanding(e.parentNode, t) : (this.lastLanding && this.lastLanding.dragLanding._dragOut(this.lastLanding, t.clientX, t.clientY, t), this.lastLanding = 0, this._onNotFound && this._onNotFound())
}, dhtmlDragAndDropObject.prototype.stopDrag = function (e, t) {
    var n = window.dhtmlDragAndDrop;
    if (!t) {
        n.stopFrameRoute();
        var r = n.lastLanding;
        n.lastLanding = null, r && r.dragLanding._drag(n.dragStartNode, n.dragStartObject, r, _isIE ? event.srcElement : e.target)
    }
    n.lastLanding = null, n.dragNode && n.dragNode.parentNode == document.body && n.dragNode.parentNode.removeChild(n.dragNode), n.dragNode = 0, n.gldragNode = 0, n.fx = 0, n.fy = 0, n.dragStartNode = 0, n.dragStartObject = 0, document.body.onmouseup = n.tempDOMU, document.body.onmousemove = n.tempDOMM, n.tempDOMU = null, n.tempDOMM = null, n.waitDrag = 0
}, dhtmlDragAndDropObject.prototype.stopFrameRoute = function (e) {
    e && window.dhtmlDragAndDrop.stopDrag(1, 1);
    for (var t = 0; t < window.frames.length; t++)try {
        window.frames[t] != e && window.frames[t].dhtmlDragAndDrop && window.frames[t].dhtmlDragAndDrop.stopFrameRoute(window)
    } catch (n) {
    }
    try {
        parent.dhtmlDragAndDrop && parent != window && parent != e && parent.dhtmlDragAndDrop.stopFrameRoute(window)
    } catch (n) {
    }
}, dhtmlDragAndDropObject.prototype.initFrameRoute = function (e, t) {
    e && (window.dhtmlDragAndDrop.preCreateDragCopy(), window.dhtmlDragAndDrop.dragStartNode = e.dhtmlDragAndDrop.dragStartNode, window.dhtmlDragAndDrop.dragStartObject = e.dhtmlDragAndDrop.dragStartObject, window.dhtmlDragAndDrop.dragNode = e.dhtmlDragAndDrop.dragNode, window.dhtmlDragAndDrop.gldragNode = e.dhtmlDragAndDrop.dragNode, window.document.body.onmouseup = window.dhtmlDragAndDrop.stopDrag, window.waitDrag = 0, !_isIE && t && (!_isFF || 1.8 > _FFrv) && window.dhtmlDragAndDrop.calculateFramePosition());
    try {
        parent.dhtmlDragAndDrop && parent != window && parent != e && parent.dhtmlDragAndDrop.initFrameRoute(window)
    } catch (n) {
    }
    for (var r = 0; r < window.frames.length; r++)try {
        window.frames[r] != e && window.frames[r].dhtmlDragAndDrop && window.frames[r].dhtmlDragAndDrop.initFrameRoute(window, !e || t ? 1 : 0)
    } catch (n) {
    }
}, _isFF = !1, _isIE = !1, _isOpera = !1, _isKHTML = !1, _isMacOS = !1, _isChrome = !1, _FFrv = !1, _KHTMLrv = !1, _OperaRv = !1, -1 != navigator.userAgent.indexOf("Macintosh") && (_isMacOS = !0), navigator.userAgent.toLowerCase().indexOf("chrome") > -1 && (_isChrome = !0), -1 != navigator.userAgent.indexOf("Safari") || -1 != navigator.userAgent.indexOf("Konqueror") ? (_KHTMLrv = parseFloat(navigator.userAgent.substr(navigator.userAgent.indexOf("Safari") + 7, 5)), _KHTMLrv > 525 ? (_isFF = !0, _FFrv = 1.9) : _isKHTML = !0) : -1 != navigator.userAgent.indexOf("Opera") ? (_isOpera = !0, _OperaRv = parseFloat(navigator.userAgent.substr(navigator.userAgent.indexOf("Opera") + 6, 3))) : -1 != navigator.appName.indexOf("Microsoft") ? (_isIE = !0, -1 == navigator.appVersion.indexOf("MSIE 8.0") && -1 == navigator.appVersion.indexOf("MSIE 9.0") && -1 == navigator.appVersion.indexOf("MSIE 10.0") || "BackCompat" == document.compatMode || (_isIE = 8)) : "Netscape" == navigator.appName && -1 != navigator.userAgent.indexOf("Trident") ? _isIE = 8 : (_isFF = !0, _FFrv = parseFloat(navigator.userAgent.split("rv:")[1])), dtmlXMLLoaderObject.prototype.doXPath = function (e, t, n, r) {
    if (_isKHTML || !_isIE && !window.XPathResult)return this.doXPathOpera(e, t);
    if (_isIE)return t || (t = this.xmlDoc.nodeName ? this.xmlDoc : this.xmlDoc.responseXML), t || dhtmlxError.throwError("LoadXML", "Incorrect XML", [t || this.xmlDoc, this.mainObject]), n && t.setProperty("SelectionNamespaces", "xmlns:xsl='" + n + "'"), "single" == r ? t.selectSingleNode(e) : t.selectNodes(e) || new Array(0);
    var i = t;
    t || (t = this.xmlDoc.nodeName ? this.xmlDoc : this.xmlDoc.responseXML), t || dhtmlxError.throwError("LoadXML", "Incorrect XML", [t || this.xmlDoc, this.mainObject]), -1 != t.nodeName.indexOf("document") ? i = t : (i = t, t = t.ownerDocument);
    var s = XPathResult.ANY_TYPE;
    "single" == r && (s = XPathResult.FIRST_ORDERED_NODE_TYPE);
    var o = [], u = t.evaluate(e, i, function () {
        return n
    }, s, null);
    if (s == XPathResult.FIRST_ORDERED_NODE_TYPE)return u.singleNodeValue;
    for (var a = u.iterateNext(); a;)o[o.length] = a, a = u.iterateNext();
    return o
}, _dhtmlxError.prototype.catchError = function (e, t) {
    this.catches[e] = t
}, _dhtmlxError.prototype.throwError = function (e, t, n) {
    return this.catches[e] ? this.catches[e](e, t, n) : this.catches.ALL ? this.catches.ALL(e, t, n) : (window.alert("Error type: " + arguments[0] + "\nDescription: " + arguments[1]), null)
}, window.dhtmlxError = new _dhtmlxError, dtmlXMLLoaderObject.prototype.doXPathOpera = function (e, t) {
    var n = e.replace(/[\/]+/gi, "/").split("/"), r = null, i = 1;
    if (!n.length)return[];
    if ("." == n[0])r = [t]; else {
        if ("" !== n[0])return[];
        r = (this.xmlDoc.responseXML || this.xmlDoc).getElementsByTagName(n[i].replace(/\[[^\]]*\]/g, "")), i++
    }
    for (i; i < n.length; i++)r = this._getAllNamedChilds(r, n[i]);
    return-1 != n[i - 1].indexOf("[") && (r = this._filterXPath(r, n[i - 1])), r
}, dtmlXMLLoaderObject.prototype._filterXPath = function (e, t) {
    for (var n = [], t = t.replace(/[^\[]*\[\@/g, "").replace(/[\[\]\@]*/g, ""), r = 0; r < e.length; r++)e[r].getAttribute(t) && (n[n.length] = e[r]);
    return n
}, dtmlXMLLoaderObject.prototype._getAllNamedChilds = function (e, t) {
    var n = [];
    _isKHTML && (t = t.toUpperCase());
    for (var r = 0; r < e.length; r++)for (var i = 0; i < e[r].childNodes.length; i++)_isKHTML ? e[r].childNodes[i].tagName && e[r].childNodes[i].tagName.toUpperCase() == t && (n[n.length] = e[r].childNodes[i]) : e[r].childNodes[i].tagName == t && (n[n.length] = e[r].childNodes[i]);
    return n
}, dtmlXMLLoaderObject.prototype.xslDoc = null, dtmlXMLLoaderObject.prototype.setXSLParamValue = function (e, t, n) {
    n || (n = this.xslDoc), n.responseXML && (n = n.responseXML);
    var r = this.doXPath("/xsl:stylesheet/xsl:variable[@name='" + e + "']", n, "http://www.w3.org/1999/XSL/Transform", "single");
    r && (r.firstChild.nodeValue = t)
}, dtmlXMLLoaderObject.prototype.doXSLTransToObject = function (e, t) {
    e || (e = this.xslDoc), e.responseXML && (e = e.responseXML), t || (t = this.xmlDoc), t.responseXML && (t = t.responseXML);
    var n;
    if (_isIE) {
        n = new ActiveXObject("Msxml2.DOMDocument.3.0");
        try {
            t.transformNodeToObject(e, n)
        } catch (r) {
            n = t.transformNode(e)
        }
    } else this.XSLProcessor || (this.XSLProcessor = new XSLTProcessor, this.XSLProcessor.importStylesheet(e)), n = this.XSLProcessor.transformToDocument(t);
    return n
}, dtmlXMLLoaderObject.prototype.doXSLTransToString = function (e, t) {
    var n = this.doXSLTransToObject(e, t);
    return"string" == typeof n ? n : this.doSerialization(n)
}, dtmlXMLLoaderObject.prototype.doSerialization = function (e) {
    if (e || (e = this.xmlDoc), e.responseXML && (e = e.responseXML), _isIE)return e.xml;
    var t = new XMLSerializer;
    return t.serializeToString(e)
}, dhtmlxEventable = function (obj) {
    obj.attachEvent = function (e, t, n) {
        return e = "ev_" + e.toLowerCase(), this[e] || (this[e] = new this.eventCatcher(n || this)), e + ":" + this[e].addEvent(t)
    }, obj.callEvent = function (e, t) {
        return e = "ev_" + e.toLowerCase(), this[e] ? this[e].apply(this, t) : !0
    }, obj.checkEvent = function (e) {
        return!!this["ev_" + e.toLowerCase()]
    }, obj.eventCatcher = function (obj) {
        var dhx_catch = [], z = function () {
            for (var e = !0, t = 0; t < dhx_catch.length; t++)if (dhx_catch[t]) {
                var n = dhx_catch[t].apply(obj, arguments);
                e = e && n
            }
            return e
        };
        return z.addEvent = function (ev) {
            return"function" != typeof ev && (ev = eval(ev)), ev ? dhx_catch.push(ev) - 1 : !1
        }, z.removeEvent = function (e) {
            dhx_catch[e] = null
        }, z
    }, obj.detachEvent = function (e) {
        if (e) {
            var t = e.split(":");
            this[t[0]].removeEvent(t[1])
        }
    }, obj.detachAllEvents = function () {
        for (var e in this)0 === e.indexOf("ev_") && (this.detachEvent(e), this[e] = null)
    }, obj = null
}, window.dhtmlx || (window.dhtmlx = {}), function () {
    function e(e, t) {
        var r = e.callback;
        n(!1), e.box.parentNode.removeChild(e.box), h = e.box = null, r && r(t)
    }

    function t(t) {
        if (h) {
            t = t || event;
            var n = t.which || event.keyCode;
            return dhtmlx.message.keyboard && ((13 == n || 32 == n) && e(h, !0), 27 == n && e(h, !1)), t.preventDefault && t.preventDefault(), !(t.cancelBubble = !0)
        }
    }

    function n(e) {
        n.cover || (n.cover = document.createElement("DIV"), n.cover.onkeydown = t, n.cover.className = "dhx_modal_cover", document.body.appendChild(n.cover));
        document.body.scrollHeight;
        n.cover.style.display = e ? "inline-block" : "none"
    }

    function r(e, t) {
        var n = "dhtmlx_" + e.toLowerCase().replace(/ /g, "_") + "_button";
        return"<div class='dhtmlx_popup_button " + n + "' result='" + t + "' ><div>" + e + "</div></div>"
    }

    function i(e) {
        p.area || (p.area = document.createElement("DIV"), p.area.className = "dhtmlx_message_area", p.area.style[p.position] = "5px", document.body.appendChild(p.area)), p.hide(e.id);
        var t = document.createElement("DIV");
        return t.innerHTML = "<div>" + e.text + "</div>", t.className = "dhtmlx-info dhtmlx-" + e.type, t.onclick = function () {
            p.hide(e.id), e = null
        }, "bottom" == p.position && p.area.firstChild ? p.area.insertBefore(t, p.area.firstChild) : p.area.appendChild(t), e.expire > 0 && (p.timers[e.id] = window.setTimeout(function () {
            p.hide(e.id)
        }, e.expire)), p.pull[e.id] = t, t = null, e.id
    }

    function s(t, n, i) {
        var s = document.createElement("DIV");
        s.className = " dhtmlx_modal_box dhtmlx-" + t.type, s.setAttribute("dhxbox", 1);
        var o = "";
        if (t.width && (s.style.width = t.width), t.height && (s.style.height = t.height), t.title && (o += '<div class="dhtmlx_popup_title">' + t.title + "</div>"), o += '<div class="dhtmlx_popup_text"><span>' + (t.content ? "" : t.text) + '</span></div><div  class="dhtmlx_popup_controls">', n && (o += r(t.ok || "OK", !0)), i && (o += r(t.cancel || "Cancel", !1)), t.buttons)for (var u = 0; u < t.buttons.length; u++)o += r(t.buttons[u], u);
        if (o += "</div>", s.innerHTML = o, t.content) {
            var a = t.content;
            "string" == typeof a && (a = document.getElementById(a)), "none" == a.style.display && (a.style.display = ""), s.childNodes[t.title ? 1 : 0].appendChild(a)
        }
        return s.onclick = function (n) {
            n = n || event;
            var r = n.target || n.srcElement;
            if (r.className || (r = r.parentNode), "dhtmlx_popup_button" == r.className.split(" ")[0]) {
                var i = r.getAttribute("result");
                i = "true" == i || ("false" == i ? !1 : i), e(t, i)
            }
        }, t.box = s, (n || i) && (h = t), s
    }

    function o(e, r, i) {
        var o = e.tagName ? e : s(e, r, i);
        e.hidden || n(!0), document.body.appendChild(o);
        var u = Math.abs(Math.floor(((window.innerWidth || document.documentElement.offsetWidth) - o.offsetWidth) / 2)), a = Math.abs(Math.floor(((window.innerHeight || document.documentElement.offsetHeight) - o.offsetHeight) / 2));
        return o.style.top = "top" == e.position ? "-3px" : a + "px", o.style.left = u + "px", o.onkeydown = t, o.focus(), e.hidden && dhtmlx.modalbox.hide(o), o
    }

    function u(e) {
        return o(e, !0, !1)
    }

    function a(e) {
        return o(e, !0, !0)
    }

    function f(e) {
        return o(e)
    }

    function l(e, t, n) {
        return"object" != typeof e && ("function" == typeof t && (n = t, t = ""), e = {text: e, type: t, callback: n}), e
    }

    function c(e, t, n, r) {
        return"object" != typeof e && (e = {text: e, type: t, expire: n, id: r}), e.id = e.id || p.uid(), e.expire = e.expire || p.expire, e
    }

    var h = null;
    document.attachEvent ? document.attachEvent("onkeydown", t) : document.addEventListener("keydown", t, !0), dhtmlx.alert = function () {
        var e = l.apply(this, arguments);
        return e.type = e.type || "confirm", u(e)
    }, dhtmlx.confirm = function () {
        var e = l.apply(this, arguments);
        return e.type = e.type || "alert", a(e)
    }, dhtmlx.modalbox = function () {
        var e = l.apply(this, arguments);
        return e.type = e.type || "alert", f(e)
    }, dhtmlx.modalbox.hide = function (e) {
        for (; e && e.getAttribute && !e.getAttribute("dhxbox");)e = e.parentNode;
        e && (e.parentNode.removeChild(e), n(!1))
    };
    var p = dhtmlx.message = function (e) {
        e = c.apply(this, arguments), e.type = e.type || "info";
        var t = e.type.split("-")[0];
        switch (t) {
            case"alert":
                return u(e);
            case"confirm":
                return a(e);
            case"modalbox":
                return f(e);
            default:
                return i(e)
        }
    };
    p.seed = (new Date).valueOf(), p.uid = function () {
        return p.seed++
    }, p.expire = 4e3, p.keyboard = !0, p.position = "top", p.pull = {}, p.timers = {}, p.hideAll = function () {
        for (var e in p.pull)p.hide(e)
    }, p.hide = function (e) {
        var t = p.pull[e];
        t && t.parentNode && (window.setTimeout(function () {
            t.parentNode.removeChild(t), t = null
        }, 2e3), t.className += " hidden", p.timers[e] && window.clearTimeout(p.timers[e]), delete p.pull[e])
    }
}(), gantt = {version: "2.1.1"}, dhtmlxEventable = function (obj) {
    obj._silent_mode = !1, obj._silentStart = function () {
        this._silent_mode = !0
    }, obj._silentEnd = function () {
        this._silent_mode = !1
    }, obj.attachEvent = function (e, t, n) {
        return e = "ev_" + e.toLowerCase(), this[e] || (this[e] = new this._eventCatcher(n || this)), e + ":" + this[e].addEvent(t)
    }, obj.callEvent = function (e, t) {
        return this._silent_mode ? !0 : (e = "ev_" + e.toLowerCase(), this[e] ? this[e].apply(this, t) : !0)
    }, obj.checkEvent = function (e) {
        return!!this["ev_" + e.toLowerCase()]
    }, obj._eventCatcher = function (obj) {
        var dhx_catch = [], z = function () {
            for (var e = !0, t = 0; t < dhx_catch.length; t++)if (dhx_catch[t]) {
                var n = dhx_catch[t].apply(obj, arguments);
                e = e && n
            }
            return e
        };
        return z.addEvent = function (ev) {
            return"function" != typeof ev && (ev = eval(ev)), ev ? dhx_catch.push(ev) - 1 : !1
        }, z.removeEvent = function (e) {
            dhx_catch[e] = null
        }, z
    }, obj.detachEvent = function (e) {
        if (e) {
            var t = e.split(":");
            this[t[0]].removeEvent(t[1])
        }
    }, obj.detachAllEvents = function () {
        for (var e in this)0 === e.indexOf("ev_") && delete this[e]
    }, obj = null
}, dhtmlx.copy = function (e) {
    var t, n, r;
    if (e && "object" == typeof e) {
        for (r = {}, n = [Array, Date, Number, String, Boolean], t = 0; t < n.length; t++)e instanceof n[t] && (r = t ? new n[t](e) : new n[t]);
        for (t in e)Object.prototype.hasOwnProperty.apply(e, [t]) && (r[t] = dhtmlx.copy(e[t]))
    }
    return r || e
}, dhtmlx.mixin = function (e, t, n) {
    for (var r in t)(!e[r] || n) && (e[r] = t[r]);
    return e
}, dhtmlx.defined = function (e) {
    return"undefined" != typeof e
}, dhtmlx.uid = function () {
    return this._seed || (this._seed = (new Date).valueOf()), this._seed++, this._seed
}, dhtmlx.bind = function (e, t) {
    return function () {
        return e.apply(t, arguments)
    }
}, gantt._get_position = function (e) {
    var t = 0, n = 0;
    if (e.getBoundingClientRect) {
        var r = e.getBoundingClientRect(), i = document.body, s = document.documentElement, o = window.pageYOffset || s.scrollTop || i.scrollTop, u = window.pageXOffset || s.scrollLeft || i.scrollLeft, a = s.clientTop || i.clientTop || 0, f = s.clientLeft || i.clientLeft || 0;
        return t = r.top + o - a, n = r.left + u - f, {y: Math.round(t), x: Math.round(n), width: e.offsetWidth, height: e.offsetHeight}
    }
    for (; e;)t += parseInt(e.offsetTop, 10), n += parseInt(e.offsetLeft, 10), e = e.offsetParent;
    return{y: t, x: n, width: e.offsetWidth, height: e.offsetHeight}
}, gantt._detectScrollSize = function () {
    var e = document.createElement("div");
    e.style.cssText = "visibility:hidden;position:absolute;left:-1000px;width:100px;padding:0px;margin:0px;height:110px;min-height:100px;overflow-y:scroll;", document.body.appendChild(e);
    var t = e.offsetWidth - e.clientWidth;
    return document.body.removeChild(e), t
}, dhtmlxEventable(gantt), gantt._click = {}, gantt._dbl_click = {}, gantt._context_menu = {}, gantt._on_click = function (e) {
    e = e || window.event;
    var t = e.target || e.srcElement, n = gantt.locate(e);
    if (null !== n) {
        var r = !gantt.checkEvent("onTaskClick") || gantt.callEvent("onTaskClick", [n, e]);
        r && gantt.config.select_task && gantt.selectTask(n)
    } else gantt.callEvent("onEmptyClick", [e]);
    gantt._find_ev_handler(e, t, gantt._click, n)
}, gantt._on_contextmenu = function (e) {
    e = e || window.event;
    var t = e.target || e.srcElement, n = gantt.locate(t), r = gantt.locate(t, gantt.config.link_attribute), i = !gantt.checkEvent("onContextMenu") || gantt.callEvent("onContextMenu", [n, r, e]);
    return i || e.preventDefault(), i
}, gantt._find_ev_handler = function (e, t, n, r) {
    for (var i = !0; t && t.parentNode;) {
        var s = t.className;
        if (s) {
            s = s.split(" ");
            for (var o = 0; o < s.length; o++)s[o] && n[s[o]] && (i = n[s[o]].call(gantt, e, r, t), i = !("undefined" != typeof i && i !== !0))
        }
        t = t.parentNode
    }
    return i
}, gantt._on_dblclick = function (e) {
    e = e || window.event;
    var t = e.target || e.srcElement, n = gantt.locate(e), r = gantt._find_ev_handler(e, t, gantt._dbl_click, n);
    if (r && null !== n) {
        var i = !gantt.checkEvent("onTaskDblClick") || gantt.callEvent("onTaskDblClick", [n, e]);
        i && gantt.config.details_on_dblclick && gantt.showLightbox(n)
    }
}, gantt._on_mousemove = function (e) {
    if (gantt.checkEvent("onMouseMove")) {
        var t = gantt.locate(e);
        gantt._last_move_event = e, gantt.callEvent("onMouseMove", [t, e])
    }
}, dhtmlxDnD.prototype = {dragStart: function (e, t) {
    this.config = {obj: e, marker: null, started: !1, pos: this.getPosition(t), sensitivity: 4}, this._settings && dhtmlx.mixin(this.config, this._settings, !0);
    var n = dhtmlx.bind(function (t) {
        return this.dragMove(e, t)
    }, this), r = (dhtmlx.bind(function (t) {
        return this.dragScroll(e, t)
    }, this), dhtmlx.bind(function (e) {
        return dhtmlx.defined(this.config.updates_per_second) && !gantt._checkTimeout(this, this.config.updates_per_second) ? !0 : n(e)
    }, this)), i = dhtmlx.bind(function () {
        return dhtmlxDetachEvent(document.body, "mousemove", r), dhtmlxDetachEvent(document.body, "mouseup", i), this.dragEnd(e)
    }, this);
    dhtmlxEvent(document.body, "mousemove", r), dhtmlxEvent(document.body, "mouseup", i), document.body.className += " gantt_noselect"
}, dragMove: function (e, t) {
    if (!this.config.marker && !this.config.started) {
        var n = this.getPosition(t), r = n.x - this.config.pos.x, i = n.y - this.config.pos.y, s = Math.sqrt(Math.pow(Math.abs(r), 2) + Math.pow(Math.abs(i), 2));
        if (s > this.config.sensitivity) {
            if (this.config.started = !0, this.config.ignore = !1, this.callEvent("onBeforeDragStart", [e, t]) === !1)return this.config.ignore = !0, !0;
            var o = this.config.marker = document.createElement("div");
            o.className = "gantt_drag_marker", o.innerHTML = "Dragging object", document.body.appendChild(o), this.callEvent("onAfterDragStart", [e, t])
        } else this.config.ignore = !0
    }
    this.config.ignore || (t.pos = this.getPosition(t), this.config.marker.style.left = t.pos.x + "px", this.config.marker.style.top = t.pos.y + "px", this.callEvent("onDragMove", [e, t]))
}, dragEnd: function () {
    this.config.marker && (this.config.marker.parentNode.removeChild(this.config.marker), this.config.marker = null, this.callEvent("onDragEnd", [])), document.body.className = document.body.className.replace(" gantt_noselect", "")
}, getPosition: function (e) {
    var t = 0, n = 0;
    return e = e || window.event, e.pageX || e.pageY ? (t = e.pageX, n = e.pageY) : (e.clientX || e.clientY) && (t = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft, n = e.clientY + document.body.scrollTop + document.documentElement.scrollTop), {x: t, y: n}
}}, gantt._init_grid = function () {
    this._click.gantt_close = dhtmlx.bind(function (e, t) {
        this.close(t)
    }, this), this._click.gantt_open = dhtmlx.bind(function (e, t) {
        this.open(t)
    }, this), this._click.gantt_row = dhtmlx.bind(function (e, t, n) {
        if (null !== t) {
            var r = this.getTaskNode(t), i = Math.max(r.offsetLeft - this.config.task_scroll_offset, 0);
            this.scrollTo(i), this.callEvent("onTaskRowClick", [t, n])
        }
    }, this), this._click.gantt_grid_head_cell = dhtmlx.bind(function (e, t, n) {
        var r = n.getAttribute("column_id");
        if (this.callEvent("onGridHeaderClick", [r, e]))if ("add" == r)this._click.gantt_add(e, this.config.root_id); else if (this.config.sort) {
            var i = this._sort && this._sort.direction && this._sort.name == r ? this._sort.direction : "desc";
            i = "desc" == i ? "asc" : "desc", this._sort = {name: r, direction: i}, this._render_grid_header(), this.sort(r, "desc" == i)
        }
    }, this), !this.config.sort && this.config.order_branch && this._init_dnd(), this._click.gantt_add = dhtmlx.bind(function (e, t) {
        if (!this.config.readonly) {
            var n = t ? this.getTask(t) : !1, r = "";
            if (n)r = n.start_date; else {
                var i = this._order[0];
                r = i ? this.getTask(i).start_date : this.getState().min_date
            }
            n && (n.$open = !0);
            var s = {text: gantt.locale.labels.new_task, start_date: this.templates.xml_format(r), duration: 1, progress: 0, parent: t};
            s.id = dhtmlx.uid(), this.callEvent("onTaskCreated", [s]), this.config.details_on_create ? (s.$new = !0, this._pull[s.id] = this._init_task(s), this._add_branch(s), s.$level = this._item_level(s), this.selectTask(s.id), this.refreshData(), this.showLightbox(s.id)) : (this.addTask(s), this.showTask(s.id), this.selectTask(s.id))
        }
    }, this)
}, gantt._render_grid = function () {
    this._is_grid_visible() && (this._calc_grid_width(), this._render_grid_header())
}, gantt._calc_grid_width = function () {
    if (this.config.autofit) {
        for (var e = this.config.columns, t = 0, n = [], r = [], i = 0; i < e.length; i++) {
            var s = parseInt(e[i].width, 10);
            window.isNaN(s) && (s = 50, n.push(i)), r[i] = s, t += s
        }
        {
            var o = this._get_grid_width() - t;
            o / (n.length > 0 ? n.length : r.length > 0 ? r.length : 1)
        }
        if (n.length > 0)for (var u = o / (n.length ? n.length : 1), i = 0; i < n.length; i++) {
            var a = n[i];
            r[a] += u
        } else for (var u = o / (r.length ? r.length : 1), i = 0; i < r.length; i++)r[i] += u;
        for (var i = 0; i < r.length; i++)e[i].width = r[i]
    }
}, gantt._render_grid_header = function () {
    for (var e = this.config.columns, t = [], n = 0, r = this.locale.labels, i = this.config.scale_height - 2, s = 0; s < e.length; s++) {
        var o = s == e.length - 1, u = e[s];
        o && this._get_grid_width() > n + u.width && (u.width = this._get_grid_width() - n), n += u.width;
        var a = this._sort && u.name == this._sort.name ? "<div class='gantt_sort gantt_" + this._sort.direction + "'></div>" : "", f = ["gantt_grid_head_cell", "gantt_grid_head_" + u.name, o ? "gantt_last_cell" : "", this.templates.grid_header_class(u.name, u)].join(" "), l = "width:" + (u.width - (o ? 1 : 0)) + "px;", c = u.label || r["column_" + u.name];
        c = c || "";
        var h = "<div class='" + f + "' style='" + l + "' column_id='" + u.name + "'>" + c + a + "</div>";
        t.push(h)
    }
    this.$grid_scale.style.height = this.config.scale_height - 1 + "px", this.$grid_scale.style.lineHeight = i + "px", this.$grid_scale.style.width = n - 1 + "px", this.$grid_scale.innerHTML = t.join("")
}, gantt._render_grid_item = function (e) {
    if (!gantt._is_grid_visible())return null;
    for (var t = this.config.columns, n = [], r = 0; r < t.length; r++) {
        var i, s, o = r == t.length - 1, u = t[r];
        "add" == u.name && r == t.length - 1 ? s = "<div class='gantt_add'></div>" : (s = u.template ? u.template(e) : e[u.name], s instanceof Date && (s = this.templates.date_grid(s)), s = "<div class='gantt_tree_content'>" + s + "</div>");
        var a = "gantt_cell" + (o ? " gantt_last_cell" : ""), f = "";
        if (u.tree) {
            for (var l = 0; l < e.$level; l++)f += this.templates.grid_indent(e);
            var c = this._branches[e.id] && this._branches[e.id].length > 0;
            c ? (f += this.templates.grid_open(e), f += this.templates.grid_folder(e)) : (f += this.templates.grid_blank(e), f += this.templates.grid_file(e))
        }
        var h = "width:" + (u.width - (o ? 1 : 0)) + "px;";
        dhtmlx.defined(u.align) && (h += "text-align:" + u.align + ";"), i = "<div class='" + a + "' style='" + h + "'>" + f + s + "</div>", n.push(i)
    }
    var a = e.$index % 2 === 0 ? "" : " odd";
    if (a += e.$transparent ? " gantt_transparent" : "", this.templates.grid_row_class) {
        var p = this.templates.grid_row_class.call(this, e.start_date, e.end_date, e);
        p && (a += " " + p)
    }
    this.getState().selected_task == e.id && (a += " gantt_selected");
    var d = document.createElement("div");
    return d.className = "gantt_row" + a, d.style.height = this.config.row_height + "px", d.style.lineHeight = gantt.config.row_height + "px", d.setAttribute(this.config.task_attribute, e.id), d.innerHTML = n.join(""), d
}, gantt.open = function (e) {
    gantt._set_item_state(e, !0), this.callEvent("onTaskOpened", [e])
}, gantt.close = function (e) {
    gantt._set_item_state(e, !1), this.callEvent("onTaskClosed", [e])
}, gantt._set_item_state = function (e, t) {
    e && this._pull[e] && (this._pull[e].$open = t, this.refreshData())
}, gantt._is_grid_visible = function () {
    return this.config.grid_width && this.config.show_grid
}, gantt._get_grid_width = function () {
    return this._is_grid_visible() ? this._is_chart_visible() ? this.config.grid_width : this._x : 0
}, gantt.getTaskIndex = function (e) {
    for (var t = this._branches[this.getTask(e).parent], n = 0; n < t.length; n++)if (t[n] == e)return n;
    return-1
}, gantt.getGlobalTaskIndex = function (e) {
    for (var t = this._order, n = 0; n < t.length; n++)if (t[n] == e)return n;
    return-1
}, gantt.moveTask = function (e, t, n) {
    var r = arguments[3];
    if (r) {
        if (r === e)return;
        n = this.getTask(r).parent, t = this.getTaskIndex(r)
    }
    n = n || this.config.root_id;
    var i = this.getTask(e), s = (this._branches[i.parent], this._branches[n]);
    if (-1 == t && (t = s.length + 1), i.parent == n) {
        var o = this.getTaskIndex(e);
        if (o == t)return;
        t > o && t--
    }
    this._replace_branch_child(i.parent, e), s = this._branches[n];
    var u = s[t];
    u ? s = s.slice(0, t).concat([e]).concat(s.slice(t)) : s.push(e), i.parent = n, this._branches[n] = s, this.refreshData()
}, gantt._init_dnd = function () {
    var e = new dhtmlxDnD(this.$grid_data, {updates_per_second: 60});
    dhtmlx.defined(this.config.dnd_sensitivity) && (e.config.sensitivity = this.config.dnd_sensitivity), e.attachEvent("onBeforeDragStart", dhtmlx.bind(function (e, t) {
        var n = this._locateHTML(t);
        if (!n)return!1;
        this.hideQuickInfo && this._hideQuickInfo();
        var r = this.locate(t);
        return this.callEvent("onRowDragStart", [r, t.target || t.srcElement, t]) ? void 0 : !1
    }, this)), e.attachEvent("onAfterDragStart", dhtmlx.bind(function (n, r) {
        var i = this._locateHTML(r);
        e.config.marker.innerHTML = i.outerHTML, e.config.id = this.locate(r);
        var s = this.getTask(e.config.id);
        s.$open = !1, s.$transparent = !0, this.refreshData()
    }, this)), e.lastTaskOfLevel = function (e) {
        for (var t = gantt._order, n = gantt._pull, r = null, i = 0, s = t.length; s > i; i++)n[t[i]].$level == e && (r = n[t[i]]);
        return r ? r.id : null
    }, e.attachEvent("onDragMove", dhtmlx.bind(function (n, r) {
        var i = e.config, s = this._get_position(this.$grid_data), o = s.x + 10, u = r.pos.y - 10;
        u < s.y && (u = s.y), u > s.y + this.$grid_data.offsetHeight - this.config.row_height && (u = s.y + this.$grid_data.offsetHeight - this.config.row_height), i.marker.style.left = o + "px", i.marker.style.top = u + "px";
        var a = document.elementFromPoint(s.x - document.body.scrollLeft + 1, u - document.body.scrollTop), f = this.locate(a), l = this.getTask(e.config.id);
        if (this.isTaskExists(f) || (f = e.lastTaskOfLevel(l.$level), f == e.config.id && (f = null)), this.isTaskExists(f)) {
            var c = gantt._get_position(a), h = this.getTask(f);
            if (c.y + a.offsetHeight / 2 < u) {
                var p = this.getGlobalTaskIndex(h.id), d = this._pull[this._order[p + 1 + (h.id == l.id ? 1 : 0)]];
                if (d) {
                    if (d.id == l.id)return;
                    h = d
                } else if (d = this._pull[this._order[p]], d.$level == l.$level)return this.moveTask(l.id, -1, d.parent), void (i.target = "next:" + d.id)
            }
            if (h.$level == l.$level && l.id != h.id)this.moveTask(l.id, 0, 0, h.id), i.target = h.id; else {
                if (l.id == h.id)return;
                var p = this.getGlobalTaskIndex(h.id), v = this._pull[this._order[p - 1]];
                v && v.$level == l.$level && l.id != v.id && (this.moveTask(l.id, -1, v.parent), i.target = "next:" + v.id)
            }
        }
        return!0
    }, this)), e.attachEvent("onDragEnd", dhtmlx.bind(function () {
        this.getTask(e.config.id).$transparent = !1, this.refreshData(), this.callEvent("onRowDragEnd", [e.config.id, e.config.target])
    }, this))
}, gantt._scale_helpers = {getSum: function (e, t, n) {
    void 0 === n && (n = e.length - 1), void 0 === t && (t = 0);
    for (var r = 0, i = t; n >= i; i++)r += e[i];
    return r
}, setSumWidth: function (e, t, n, r) {
    var i = t.width;
    void 0 === r && (r = i.length - 1), void 0 === n && (n = 0);
    var s = r - n + 1;
    if (!(n > i.length - 1 || 0 >= s || r > i.length - 1)) {
        var o = this.getSum(i, n, r), u = e - o;
        this.adjustSize(u, i, n, r), this.adjustSize(-u, i, r + 1), t.full_width = this.getSum(i)
    }
}, splitSize: function (e, t) {
    for (var n = [], r = 0; t > r; r++)n[r] = 0;
    return this.adjustSize(e, n), n
}, adjustSize: function (e, t, n, r) {
    n || (n = 0), void 0 === r && (r = t.length - 1);
    for (var i = r - n + 1, s = this.getSum(t, n, r), o = 0, u = n; r >= u; u++) {
        var a = Math.floor(e * (s ? t[u] / s : 1 / i));
        s -= t[u], e -= a, i--, t[u] += a, o += a
    }
    t[t.length - 1] += e
}, sortScales: function (e) {
    function t(e, t) {
        var n = new Date(1970, 0, 1);
        return gantt.date.add(n, t, e) - n
    }

    e.sort(function (e, n) {
        return t(e.unit, e.step) < t(n.unit, n.step) ? 1 : -1
    })
}, primaryScale: function () {
    return gantt._init_template("date_scale"), {unit: gantt.config.scale_unit, step: gantt.config.step, template: gantt.templates.date_scale, date: gantt.config.date_scale, css: gantt.templates.scale_cell_class}
}, prepareConfigs: function (e, t, n, r) {
    for (var i = this.splitSize(r, e.length), s = n, o = [], u = e.length - 1; u >= 0; u--) {
        var a = u == e.length - 1, f = this.initScaleConfig(e[u]);
        a && this.processIgnores(f), this.initColSizes(f, t, s, i[u]), this.limitVisibleRange(f), a && (s = f.full_width), o.unshift(f)
    }
    for (var u = 0; u < o.length - 1; u++)this.alineScaleColumns(o[o.length - 1], o[u]);
    return o
}, _ignore_time_config: function (e) {
    return this.config.skip_off_time ? !this.isWorkTime(e) : !1
}, processIgnores: function (e) {
    var t = e.count;
    if (e.ignore_x = {}, gantt.ignore_time || gantt.config.skip_off_time) {
        var n = gantt.ignore_time || function () {
            return!1
        };
        t = 0;
        for (var r = 0; r < e.trace_x.length; r++)n.call(gantt, e.trace_x[r]) || this._ignore_time_config.call(gantt, e.trace_x[r]) ? (e.ignore_x[e.trace_x[r].valueOf()] = !0, e.ignored_colls = !0) : t++
    }
    e.display_count = t
}, initColSizes: function (e, t, n, r) {
    var i = n;
    e.height = r;
    var s = void 0 === e.display_count ? e.count : e.display_count;
    s || (s = 1), e.col_width = Math.floor(i / s), t && e.col_width < t && (e.col_width = t, i = e.col_width * s), e.width = [];
    for (var o = e.ignore_x || {}, u = 0; u < e.trace_x.length; u++)e.width[u] = o[e.trace_x[u].valueOf()] || e.display_count == e.count ? 0 : 1;
    this.adjustSize(i - this.getSum(e.width), e.width), e.full_width = this.getSum(e.width)
}, initScaleConfig: function (e) {
    var t = dhtmlx.mixin({count: 0, col_width: 0, full_width: 0, height: 0, width: [], trace_x: []}, e);
    return this.eachColumn(e.unit, e.step, function (e) {
        t.count++, t.trace_x.push(new Date(e))
    }), t
}, iterateScales: function (e, t, n, r, i) {
    for (var s = t.trace_x, o = e.trace_x, u = n || 0, a = r || o.length - 1, f = 0, l = 1; l < s.length; l++)for (var c = u; a >= c; c++)+o[c] != +s[l] || (i && i.apply(this, [f, l, u, c]), u = c, f = l)
}, alineScaleColumns: function (e, t, n, r) {
    this.iterateScales(e, t, n, r, function (n, r, i, s) {
        var o = this.getSum(e.width, i, s - 1), u = this.getSum(t.width, n, r - 1);
        u != o && this.setSumWidth(o, t, n, r - 1)
    })
}, eachColumn: function (e, t, n) {
    var r = new Date(gantt._min_date), i = new Date(gantt._max_date);
    gantt.date[e + "_start"] && (r = gantt.date[e + "_start"](r));
    for (var s = new Date(r); +i > +s;)n.call(this, new Date(s)), s = gantt.date.add(s, t, e)
}, limitVisibleRange: function (e) {
    var t = e.trace_x, n = 0, r = e.width.length - 1, i = 0;
    if (+t[0] < +gantt._min_date && n != r) {
        var s = Math.floor(e.width[0] * ((t[1] - gantt._min_date) / (t[1] - t[0])));
        i += e.width[0] - s, e.width[0] = s, t[0] = new Date(gantt._min_date)
    }
    var o = t.length - 1, u = t[o], a = gantt.date.add(u, e.step, e.unit);
    if (+a > +gantt._max_date && o > 0) {
        var s = e.width[o] - Math.floor(e.width[o] * ((a - gantt._max_date) / (a - u)));
        i += e.width[o] - s, e.width[o] = s
    }
    if (i) {
        for (var f = this.getSum(e.width), l = 0, c = 0; c < e.width.length; c++) {
            var h = Math.floor(i * (e.width[c] / f));
            e.width[c] += h, l += h
        }
        this.adjustSize(i - l, e.width)
    }
}}, gantt._tasks_dnd = {drag: null, _events: {before_start: {}, before_finish: {}, after_finish: {}}, _handlers: {}, init: function () {
    this.clear_drag_state();
    var e = gantt.config.drag_mode;
    this.set_actions();
    var t = {before_start: "onBeforeTaskDrag", before_finish: "onBeforeTaskChanged", after_finish: "onAfterTaskDrag"};
    for (var n in this._events)for (var r in e)this._events[n][r] = t[n];
    this._handlers[e.move] = this._move, this._handlers[e.resize] = this._resize, this._handlers[e.progress] = this._resize_progress
}, set_actions: function () {
    var e = gantt.$task_data;
    dhtmlxEvent(e, "mousemove", dhtmlx.bind(function (e) {
        this.on_mouse_move(e || event)
    }, this)), dhtmlxEvent(e, "mousedown", dhtmlx.bind(function (e) {
        this.on_mouse_down(e || event)
    }, this)), dhtmlxEvent(e, "mouseup", dhtmlx.bind(function (e) {
        this.on_mouse_up(e || event)
    }, this))
}, clear_drag_state: function () {
    this.drag = {id: null, mode: null, pos: null, start_x: null, start_y: null, obj: null, left: null}
}, _resize: function (e, t, n) {
    var r = gantt.config, i = this._drag_task_coords(e, n);
    n.left ? (e.start_date = gantt._date_from_pos(i.start + t), e.start_date || (e.start_date = new Date(gantt.getState().min_date))) : (e.end_date = gantt._date_from_pos(i.end + t), e.end_date || (e.end_date = new Date(gantt.getState().max_date))), e.end_date - e.start_date < r.min_duration && (n.left ? e.start_date = gantt.calculateEndDate(e.end_date, -1) : e.end_date = gantt.calculateEndDate(e.start_date, 1)), gantt._init_task_timing(e)
}, _resize_progress: function (e, t, n) {
    var r = this._drag_task_coords(e, n), i = Math.max(0, n.pos.x - r.start);
    e.progress = Math.min(1, i / (r.end - r.start))
}, _move: function (e, t, n) {
    var r = this._drag_task_coords(e, n), i = gantt._date_from_pos(r.start + t), s = gantt._date_from_pos(r.end + t);
    i ? s ? (e.start_date = i, e.end_date = s) : (e.end_date = new Date(gantt.getState().max_date), e.start_date = gantt._date_from_pos(gantt.posFromDate(e.end_date) - (r.end - r.start))) : (e.start_date = new Date(gantt.getState().min_date), e.end_date = gantt._date_from_pos(gantt.posFromDate(e.start_date) + (r.end - r.start)))
}, _drag_task_coords: function (e, t) {
    var n = t.obj_s_x = t.obj_s_x || gantt.posFromDate(e.start_date), r = t.obj_e_x = t.obj_e_x || gantt.posFromDate(e.end_date);
    return{start: n, end: r}
}, on_mouse_move: function (e) {
    this.drag.start_drag && this._start_dnd(e);
    var t = this.drag;
    if (t.mode) {
        if (!gantt._checkTimeout(this, 40))return;
        this._update_on_move(e)
    }
}, _update_on_move: function (e) {
    var t = this.drag;
    if (t.mode) {
        var n = gantt._get_mouse_pos(e);
        if (t.pos && t.pos.x == n.x)return;
        t.pos = n;
        var r = gantt._date_from_pos(n.x);
        if (!r || isNaN(r.getTime()))return;
        var i = n.x - t.start_x, s = gantt.getTask(t.id);
        if (this._handlers[t.mode]) {
            var o = dhtmlx.mixin({}, s), u = dhtmlx.mixin({}, s);
            this._handlers[t.mode].apply(this, [u, i, t]), dhtmlx.mixin(s, u, !0), gantt._update_parents(t.id, !0), gantt.callEvent("onTaskDrag", [s.id, t.mode, u, o, e]), dhtmlx.mixin(s, u, !0), gantt._update_parents(t.id), gantt.refreshTask(t.id)
        }
    }
}, on_mouse_down: function (e, t) {
    if (2 != e.button && !gantt.config.readonly && !this.drag.mode) {
        this.clear_drag_state(), t = t || e.target || e.srcElement;
        var n = gantt._trim(t.className || "");
        if (!n || !this._get_drag_mode(n))return t.parentNode ? this.on_mouse_down(e, t.parentNode) : void 0;
        var r = this._get_drag_mode(n);
        if (r)if (r.mode && r.mode != gantt.config.drag_mode.ignore && gantt.config["drag_" + r.mode]) {
            var i = gantt.locate(t), s = dhtmlx.copy(gantt.getTask(i) || {});
            if (gantt._is_flex_task(s) && r.mode != gantt.config.drag_mode.progress)return void this.clear_drag_state();
            r.id = i;
            var o = gantt._get_mouse_pos(e);
            r.start_x = o.x, r.start_y = o.y, r.obj = s, this.drag.start_drag = r
        } else this.clear_drag_state(); else if (gantt.checkEvent("onMouseDown") && gantt.callEvent("onMouseDown", [n.split(" ")[0]]) && t.parentNode)return this.on_mouse_down(e, t.parentNode)
    }
}, _fix_dnd_scale_time: function (e, t) {
    var n = gantt._tasks.unit, r = gantt._tasks.step;
    gantt.config.round_dnd_dates || (n = "minute", r = gantt.config.time_step), t.mode == gantt.config.drag_mode.resize ? t.left ? e.start_date = gantt._get_closest_date({date: e.start_date, unit: n, step: r}) : e.end_date = gantt._get_closest_date({date: e.end_date, unit: n, step: r}) : t.mode == gantt.config.drag_mode.move && (e.start_date = gantt._get_closest_date({date: e.start_date, unit: n, step: r}), e.end_date = gantt.calculateEndDate(e.start_date, e.duration, gantt.config.duration_unit))
}, _fix_working_times: function (e, t) {
    gantt.config.work_time && gantt.config.correct_work_time && (t.mode == gantt.config.drag_mode.resize ? t.left ? e.start_date = gantt.getClosestWorkTime({date: e.start_date, dir: "future"}) : e.end_date = gantt.getClosestWorkTime({date: e.end_date, dir: "past"}) : t.mode == gantt.config.drag_mode.move && (gantt.isWorkTime(e.start_date) ? gantt.isWorkTime(new Date(+e.end_date - 1)) || (e.end_date = gantt.getClosestWorkTime({date: e.end_date, dir: "past"}), e.start_date = gantt.calculateEndDate(e.end_date, -1 * e.duration)) : (e.start_date = gantt.getClosestWorkTime({date: e.start_date, dir: "future"}), e.end_date = gantt.calculateEndDate(e.start_date, e.duration))))
}, on_mouse_up: function (e) {
    var t = this.drag;
    if (t.mode && t.id) {
        var n = gantt.getTask(t.id);
        if (gantt.config.work_time && gantt.config.correct_work_time && this._fix_working_times(n, t), gantt._fix_dnd_scale_time(n, t), gantt._init_task_timing(n), this._fireEvent("before_finish", t.mode, [t.id, t.mode, dhtmlx.copy(t.obj), e])) {
            var r = t.id;
            gantt._init_task_timing(n), gantt.updateTask(n.id), this._fireEvent("after_finish", t.mode, [r, t.mode, e]), this.clear_drag_state()
        } else t.obj._dhx_changed = !1, dhtmlx.mixin(n, t.obj, !0), gantt.updateTask(n.id)
    }
    this.clear_drag_state()
}, _get_drag_mode: function (e) {
    var t = gantt.config.drag_mode, n = (e || "").split(" "), r = n[0], i = {mode: null, left: null};
    switch (r) {
        case"gantt_task_line":
        case"gantt_task_content":
            i.mode = t.move;
            break;
        case"gantt_task_drag":
            i.mode = t.resize, i.left = n[1] && -1 !== n[1].indexOf("left", n[1].length - "left".length) ? !0 : !1;
            break;
        case"gantt_task_progress_drag":
            i.mode = t.progress;
            break;
        case"gantt_link_control":
        case"gantt_link_point":
            i.mode = t.ignore;
            break;
        default:
            i = null
    }
    return i
}, _start_dnd: function (e) {
    var t = this.drag = this.drag.start_drag;
    delete t.start_drag;
    var n = gantt.config, r = t.id;
    n["drag_" + t.mode] && gantt.callEvent("onBeforeDrag", [r, t.mode, e]) && this._fireEvent("before_start", t.mode, [r, t.mode, e]) ? delete t.start_drag : this.clear_drag_state()
}, _fireEvent: function (e, t, n) {
    dhtmlx.assert(this._events[e], "Invalid stage:{" + e + "}");
    var r = this._events[e][t];
    return dhtmlx.assert(r, "Unknown after drop mode:{" + t + "}"), dhtmlx.assert(n, "Invalid event arguments"), gantt.checkEvent(r) ? gantt.callEvent(r, n) : !0
}}, gantt._render_link = function (e) {
    var t = this.getLink(e);
    gantt._linkRenderer.render_item(t, this.$task_links)
}, gantt._get_link_type = function (e, t) {
    var n = null;
    return e && t ? n = gantt.config.links.start_to_start : !e && t ? n = gantt.config.links.finish_to_start : e || t ? e && !t && (n = gantt.config.links.start_to_finish) : n = gantt.config.links.finish_to_finish, n
}, gantt.isLinkAllowed = function (e, t, n, r) {
    var i = null;
    if (i = "object" == typeof e ? e : {source: e, target: t, type: this._get_link_type(n, r)}, !i)return!1;
    if (!(i.source && i.target && i.type))return!1;
    if (i.source == i.target)return!1;
    var s = !0;
    return this.checkEvent("onLinkValidation") && (s = this.callEvent("onLinkValidation", [i])), s
}, gantt._render_link_element = function (e) {
    var t = this._path_builder.get_points(e), n = gantt._drawer, r = n.get_lines(t), i = document.createElement("div"), s = "gantt_task_link", o = this.templates.link_class ? this.templates.link_class(e) : "";
    o && (s += " " + o), i.className = s, i.setAttribute(gantt.config.link_attribute, e.id);
    for (var u = 0; u < r.length; u++)u == r.length - 1 && (r[u].size -= gantt.config.link_arrow_size), i.appendChild(n.render_line(r[u], r[u + 1]));
    var a = r[r.length - 1].direction, f = gantt._render_link_arrow(t[t.length - 1], a);
    return i.appendChild(f), i
}, gantt._render_link_arrow = function (e, t) {
    var n = document.createElement("div"), r = gantt._drawer, i = e.y, s = e.x, o = gantt.config.link_arrow_size, u = gantt.config.row_height, a = "gantt_link_arrow gantt_link_arrow_" + t;
    switch (t) {
        case r.dirs.right:
            i -= (o - u) / 2, s -= o;
            break;
        case r.dirs.left:
            i -= (o - u) / 2;
            break;
        case r.dirs.up:
            s -= (o - u) / 2;
            break;
        case r.dirs.down:
            i -= o, s -= (o - u) / 2
    }
    return n.style.cssText = ["top:" + i + "px", "left:" + s + "px"].join(";"), n.className = a, n
}, gantt._drawer = {current_pos: null, dirs: {left: "left", right: "right", up: "up", down: "down"}, path: [], clear: function () {
    this.current_pos = null, this.path = []
}, point: function (e) {
    this.current_pos = dhtmlx.copy(e)
}, get_lines: function (e) {
    this.clear(), this.point(e[0]);
    for (var t = 1; t < e.length; t++)this.line_to(e[t]);
    return this.get_path()
}, line_to: function (e) {
    var t = dhtmlx.copy(e), n = this.current_pos, r = this._get_line(n, t);
    this.path.push(r), this.current_pos = t
}, get_path: function () {
    return this.path
}, get_wrapper_sizes: function (e) {
    var t, n = gantt.config.link_wrapper_width, r = (gantt.config.link_line_width, e.y + (gantt.config.row_height - n) / 2);
    switch (e.direction) {
        case this.dirs.left:
            t = {top: r, height: n, lineHeight: n, left: e.x - e.size - n / 2, width: e.size + n};
            break;
        case this.dirs.right:
            t = {top: r, lineHeight: n, height: n, left: e.x - n / 2, width: e.size + n};
            break;
        case this.dirs.up:
            t = {top: r - e.size, lineHeight: e.size + n, height: e.size + n, left: e.x - n / 2, width: n};
            break;
        case this.dirs.down:
            t = {top: r, lineHeight: e.size + n, height: e.size + n, left: e.x - n / 2, width: n}
    }
    return t
}, get_line_sizes: function (e) {
    var t, n = gantt.config.link_line_width, r = gantt.config.link_wrapper_width, i = e.size + n;
    switch (e.direction) {
        case this.dirs.left:
        case this.dirs.right:
            t = {height: n, width: i, marginTop: (r - n) / 2, marginLeft: (r - n) / 2};
            break;
        case this.dirs.up:
        case this.dirs.down:
            t = {height: i, width: n, marginTop: (r - n) / 2, marginLeft: (r - n) / 2}
    }
    return t
}, render_line: function (e) {
    var t = this.get_wrapper_sizes(e), n = document.createElement("div");
    n.style.cssText = ["top:" + t.top + "px", "left:" + t.left + "px", "height:" + t.height + "px", "width:" + t.width + "px"].join(";"), n.className = "gantt_line_wrapper";
    var r = this.get_line_sizes(e), i = document.createElement("div");
    return i.style.cssText = ["height:" + r.height + "px", "width:" + r.width + "px", "margin-top:" + r.marginTop + "px", "margin-left:" + r.marginLeft + "px"].join(";"), i.className = "gantt_link_line_" + e.direction, n.appendChild(i), n
}, _get_line: function (e, t) {
    var n = this.get_direction(e, t), r = {x: e.x, y: e.y, direction: this.get_direction(e, t)};
    return r.size = Math.abs(n == this.dirs.left || n == this.dirs.right ? e.x - t.x : e.y - t.y), r
}, get_direction: function (e, t) {
    var n = 0;
    return n = t.x < e.x ? this.dirs.left : t.x > e.x ? this.dirs.right : t.y > e.y ? this.dirs.down : this.dirs.up
}}, gantt._y_from_ind = function (e) {
    return e * gantt.config.row_height
}, gantt._path_builder = {path: [], clear: function () {
    this.path = []
}, current: function () {
    return this.path[this.path.length - 1]
}, point: function (e) {
    return e ? (this.path.push(dhtmlx.copy(e)), e) : this.current()
}, point_to: function (e, t, n) {
    n = n ? {x: n.x, y: n.y} : dhtmlx.copy(this.point());
    var r = gantt._drawer.dirs;
    switch (e) {
        case r.left:
            n.x -= t;
            break;
        case r.right:
            n.x += t;
            break;
        case r.up:
            n.y -= t;
            break;
        case r.down:
            n.y += t
    }
    return this.point(n)
}, get_points: function (e) {
    var t = this.get_endpoint(e), n = gantt.config, r = t.e_y - t.y, i = t.e_x - t.x, s = gantt._drawer.dirs;
    this.clear(), this.point({x: t.x, y: t.y});
    var o = 2 * n.link_arrow_size, u = t.e_x > t.x;
    if (e.type == gantt.config.links.start_to_start)this.point_to(s.left, o), u ? (this.point_to(s.down, r), this.point_to(s.right, i)) : (this.point_to(s.right, i), this.point_to(s.down, r)), this.point_to(s.right, o); else if (e.type == gantt.config.links.finish_to_start)if (u = t.e_x > t.x + 2 * o, this.point_to(s.right, o), u)i -= o, this.point_to(s.down, r), this.point_to(s.right, i); else {
        i -= 2 * o;
        var a = r > 0 ? 1 : -1;
        this.point_to(s.down, a * (n.row_height / 2)), this.point_to(s.right, i), this.point_to(s.down, a * (Math.abs(r) - n.row_height / 2)), this.point_to(s.right, o)
    } else if (e.type == gantt.config.links.finish_to_finish)this.point_to(s.right, o), u ? (this.point_to(s.right, i), this.point_to(s.down, r)) : (this.point_to(s.down, r), this.point_to(s.right, i)), this.point_to(s.left, o); else if (e.type == gantt.config.links.start_to_finish)if (u = t.e_x > t.x - 2 * o, this.point_to(s.left, o), u) {
        i += 2 * o;
        var a = r > 0 ? 1 : -1;
        this.point_to(s.down, a * (n.row_height / 2)), this.point_to(s.right, i), this.point_to(s.down, a * (Math.abs(r) - n.row_height / 2)), this.point_to(s.left, o)
    } else i += o, this.point_to(s.down, r), this.point_to(s.right, i);
    return this.path
}, get_endpoint: function (e) {
    var t = gantt.config.links, n = !1, r = !1;
    e.type == t.start_to_start ? n = r = !0 : e.type == t.finish_to_finish ? n = r = !1 : e.type == t.finish_to_start ? (n = !1, r = !0) : e.type == t.start_to_finish ? (n = !0, r = !1) : dhtmlx.assert(!1, "Invalid link type");
    var i = gantt._get_task_visible_pos(gantt._pull[e.source], n), s = gantt._get_task_visible_pos(gantt._pull[e.target], r);
    return{x: i.x, e_x: s.x, y: i.y, e_y: s.y}
}}, gantt._init_links_dnd = function () {
    function e(e, t, n) {
        var r = gantt._get_task_pos(e, !!t);
        return r.y += gantt._get_task_height() / 2, n = n || 0, r.x += (t ? -1 : 1) * n, r
    }

    function t(e) {
        var t = r(), n = ["gantt_link_tooltip"];
        t.from && t.to && n.push(gantt.isLinkAllowed(t.from, t.to, t.from_start, t.to_start) ? "gantt_allowed_link" : "gantt_invalid_link");
        var i = gantt.templates.drag_link_class(t.from, t.from_start, t.to, t.to_start);
        i && n.push(i);
        var s = "<div class='" + i + "'>" + gantt.templates.drag_link(t.from, t.from_start, t.to, t.to_start) + "</div>";
        e.innerHTML = s
    }

    function n(e, t) {
        e.style.left = t.x + 5 + "px", e.style.top = t.y + 5 + "px"
    }

    function r() {
        return{from: gantt._link_source_task, to: gantt._link_target_task, from_start: gantt._link_source_task_start, to_start: gantt._link_target_task_start}
    }

    function i() {
        gantt._link_source_task = gantt._link_source_task_start = gantt._link_target_task = null, gantt._link_target_task_start = !0
    }

    function s(e, t, n, i) {
        var s = a(), f = r(), l = ["gantt_link_direction"];
        gantt.templates.link_direction_class && l.push(gantt.templates.link_direction_class(f.from, f.from_start, f.to, f.to_start));
        var c = Math.sqrt(Math.pow(n - e, 2) + Math.pow(i - t, 2));
        if (c = Math.max(0, c - 3)) {
            s.className = l.join(" ");
            var h = (i - t) / (n - e), p = Math.atan(h);
            2 == u(e, n, t, i) ? p += Math.PI : 3 == u(e, n, t, i) && (p -= Math.PI);
            var d = Math.sin(p), v = Math.cos(p), m = Math.round(t), g = Math.round(e), y = ["-webkit-transform: rotate(" + p + "rad)", "-moz-transform: rotate(" + p + "rad)", "-ms-transform: rotate(" + p + "rad)", "-o-transform: rotate(" + p + "rad)", "transform: rotate(" + p + "rad)", "width:" + Math.round(c) + "px"];
            if (-1 != window.navigator.userAgent.indexOf("MSIE 8.0")) {
                y.push('-ms-filter: "' + o(d, v) + '"');
                var b = Math.abs(Math.round(e - n)), w = Math.abs(Math.round(i - t));
                switch (u(e, n, t, i)) {
                    case 1:
                        m -= w;
                        break;
                    case 2:
                        g -= b, m -= w;
                        break;
                    case 3:
                        g -= b
                }
            }
            y.push("top:" + m + "px"), y.push("left:" + g + "px"), s.style.cssText = y.join(";")
        }
    }

    function o(e, t) {
        return"progid:DXImageTransform.Microsoft.Matrix(M11 = " + t + ",M12 = -" + e + ",M21 = " + e + ",M22 = " + t + ",SizingMethod = 'auto expand')"
    }

    function u(e, t, n, r) {
        return t >= e ? n >= r ? 1 : 4 : n >= r ? 2 : 3
    }

    function a() {
        return l._direction || (l._direction = document.createElement("div"), gantt.$task_links.appendChild(l._direction)), l._direction
    }

    function f() {
        l._direction && (l._direction.parentNode && l._direction.parentNode.removeChild(l._direction), l._direction = null)
    }

    var l = new dhtmlxDnD(this.$task_bars, {sensitivity: 0, updates_per_second: 60}), c = "task_left", h = "task_right", p = "gantt_link_point", d = "gantt_link_control";
    l.attachEvent("onBeforeDragStart", dhtmlx.bind(function (t, n) {
        if (gantt.config.readonly)return!1;
        var r = n.target || n.srcElement;
        if (i(), gantt.getState().drag_id)return!1;
        if (gantt._locate_css(r, p)) {
            gantt._locate_css(r, c) && (gantt._link_source_task_start = !0);
            var s = gantt._link_source_task = this.locate(n), o = gantt.getTask(s), u = 0;
            return o.type == gantt.config.types.milestone && (u = (gantt._get_visible_milestone_width() - gantt._get_milestone_width()) / 2), this._dir_start = e(o, !!gantt._link_source_task_start, u), !0
        }
        return!1
    }, this)), l.attachEvent("onAfterDragStart", dhtmlx.bind(function () {
        t(l.config.marker)
    }, this)), l.attachEvent("onDragMove", dhtmlx.bind(function (r, i) {
        var o = l.config, u = l.getPosition(i);
        n(o.marker, u);
        var a = gantt._is_link_drop_area(i), f = gantt._link_target_task, c = gantt._link_landing, p = gantt._link_target_task_start, v = gantt.locate(i), m = !0;
        if (a && (m = !gantt._locate_css(i, h), a = !!v), gantt._link_target_task = v, gantt._link_landing = a, gantt._link_target_task_start = m, a) {
            var g = gantt.getTask(v), y = gantt._locate_css(i, d), b = 0;
            y && (b = Math.floor(y.offsetWidth / 2)), this._dir_end = e(g, !!gantt._link_target_task_start, b)
        } else this._dir_end = gantt._get_mouse_pos(i);
        var w = !(c == a && f == v && p == m);
        return w && (f && gantt.refreshTask(f, !1), v && gantt.refreshTask(v, !1)), w && t(o.marker), s(this._dir_start.x, this._dir_start.y, this._dir_end.x, this._dir_end.y), !0
    }, this)), l.attachEvent("onDragEnd", dhtmlx.bind(function () {
        var e = r();
        if (e.from && e.to && e.from != e.to) {
            var t = gantt._get_link_type(e.from_start, e.to_start);
            t && gantt.addLink({source: e.from, target: e.to, type: t})
        }
        i(), e.from && gantt.refreshTask(e.from, !1), e.to && gantt.refreshTask(e.to, !1), f()
    }, this)), gantt._is_link_drop_area = function (e) {
        return!!gantt._locate_css(e, d)
    }
}, gantt._get_link_state = function () {
    return{link_landing_area: this._link_landing, link_target_id: this._link_target_task, link_target_start: this._link_target_task_start, link_source_id: this._link_source_task, link_source_start: this._link_source_task_start}
}, gantt._init_tasks = function () {
    function e(e, t, n, r) {
        for (var i = 0; i < e.length; i++)e[i].change_id(t, n), e[i].render_item(r)
    }

    this._tasks = {col_width: this.config.columnWidth, width: [], full_width: 0, trace_x: [], rendered: {}}, this._click.gantt_task_link = dhtmlx.bind(function (e) {
        var t = this.locate(e, gantt.config.link_attribute);
        t && this.callEvent("onLinkClick", [t, e])
    }, this), this._dbl_click.gantt_task_link = dhtmlx.bind(function (e, t) {
        var t = this.locate(e, gantt.config.link_attribute);
        this._delete_link_handler(t, e)
    }, this), this._dbl_click.gantt_link_point = dhtmlx.bind(function (e, t, n) {
        var t = this.locate(e), r = this.getTask(t), i = null;
        return n.parentNode && n.parentNode.className && (i = n.parentNode.className.indexOf("_left") > -1 ? r.$target[0] : r.$source[0]), i && this._delete_link_handler(i, e), !1
    }, this), this._tasks_dnd.init(), this._init_links_dnd();
    var t = this._create_filter("_filter_task", "_is_grid_visible"), n = this._create_filter("_filter_task", "_is_chart_visible"), r = this._create_filter("_filter_link", "_is_chart_visible");
    this._taskRenderer = gantt._task_renderer("line", this._render_task_element, this.$task_bars, n), this._linkRenderer = gantt._task_renderer("links", this._render_link_element, this.$task_links, r), this._gridRenderer = gantt._task_renderer("grid_items", this._render_grid_item, this.$grid_data, t), this._bgRenderer = gantt._task_renderer("bg_lines", this._render_bg_line, this.$task_bg, n), this.attachEvent("onTaskIdChange", function (t, n) {
        var r = this._get_task_renderers();
        e(r, t, n, this.getTask(n))
    }), this.attachEvent("onLinkIdChange", function (t, n) {
        var r = this._get_link_renderers();
        e(r, t, n, this.getLink(n))
    })
}, gantt._create_filter = function (e) {
    return e instanceof Array || (e = Array.prototype.slice.call(arguments, 0)), function (n) {
        for (var r = !0, i = 0, s = e.length; s > i; i++) {
            var o = e[i];
            gantt[o] && (r = r && gantt[o].apply(gantt, [n.id, n]) !== !1)
        }
        return r
    }
}, gantt._is_chart_visible = function () {
    return!!this.config.show_chart
}, gantt._filter_task = function (e, t) {
    var n = null, r = null;
    return this.config.start_date && this.config.end_date && (n = this.config.start_date.valueOf(), r = this.config.end_date.valueOf(), +t.start_date > r || +t.end_date < +n) ? !1 : !0
}, gantt._filter_link = function (e, t) {
    return this.config.show_links && gantt.isTaskVisible(t.source) && gantt.isTaskVisible(t.target) ? this.callEvent("onBeforeLinkDisplay", [e, t]) : !1
}, gantt._get_task_renderers = function () {
    return[this._taskRenderer, this._gridRenderer, this._bgRenderer]
}, gantt._get_link_renderers = function () {
    return[this._linkRenderer]
}, gantt._delete_link_handler = function (e, t) {
    if (e && this.callEvent("onLinkDblClick", [e, t])) {
        if (this.config.readonly)return;
        var n = "", r = gantt.locale.labels.link + " " + this.templates.link_description(this.getLink(e)) + " " + gantt.locale.labels.confirm_link_deleting;
        window.setTimeout(function () {
            gantt._dhtmlx_confirm(r, n, function () {
                gantt.deleteLink(e)
            })
        }, gantt.config.touch ? 300 : 1)
    }
}, gantt.getTaskNode = function (e) {
    return this._taskRenderer.rendered[e]
},gantt.getLinkNode = function (e) {
    return this._linkRenderer.rendered[e]
},gantt._get_tasks_data = function () {
    for (var e = [], t = 0; t < this._order.length; t++) {
        var n = this._pull[this._order[t]];
        n.$index = t, this._update_parents(n.id, !0), e.push(n)
    }
    return e
},gantt._get_links_data = function () {
    var e = [];
    for (var t in this._lpull)e.push(this._lpull[t]);
    return e
},gantt._render_data = function () {
    this._update_layout_sizes();
    for (var e = this._get_tasks_data(), t = this._get_task_renderers(), n = 0; n < t.length; n++)t[n].render_items(e);
    var r = gantt._get_links_data();
    t = this._get_link_renderers();
    for (var n = 0; n < t.length; n++)t[n].render_items(r)
},gantt._update_layout_sizes = function () {
    var e = this._tasks;
    if (e.bar_height = this._get_task_height(), this.$task_data.style.height = Math.max(this.$task.offsetHeight - this.config.scale_height, 0) + "px", this.$task_bg.style.width = e.full_width + "px", this._is_grid_visible()) {
        for (var t = this.config.columns, n = 0, r = 0; r < t.length; r++)n += t[r].width;
        this.$grid_data.style.width = Math.max(n - 1, 0) + "px"
    }
},gantt._init_tasks_range = function () {
    var e = this.config.scale_unit;
    if (this.config.start_date && this.config.end_date)return this._min_date = this.date[e + "_start"](new Date(this.config.start_date)), void (this._max_date = this.date[e + "_start"](new Date(this.config.end_date)));
    var t = this._get_tasks_data(), n = this._init_task({id: this.config.root_id});
    t.push(n);
    var r = -1 / 0, i = 1 / 0;
    this.eachTask(function (e) {
        e.end_date && +e.end_date > +r && (r = new Date(e.end_date))
    }, this.config.root_id), this.eachTask(function (e) {
        e.start_date && +e.start_date < +i && (i = new Date(e.start_date))
    }, this.config.root_id), this._min_date = i, this._max_date = r, r && r != -1 / 0 || (this._min_date = new Date, this._max_date = new Date(this._min_date)), this._min_date = this.date[e + "_start"](this._min_date), +this._min_date == +i && (this._min_date = this.date.add(this.date[e + "_start"](this._min_date), -1, e)), this._max_date = this.date[e + "_start"](this._max_date), this._max_date = this.date.add(this._max_date, 1, e)
},gantt._prepare_scale_html = function (e) {
    var t = [], n = null, r = null, i = null;
    (e.template || e.date) && (r = e.template || this.date.date_to_str(e.date)), i = e.css || gantt.templates.scale_cell_class;
    for (var s = 0; s < e.count; s++) {
        n = new Date(e.trace_x[s]);
        var o = r.call(this, n), u = e.width[s], a = "", f = "", l = "";
        if (u) {
            a = "width:" + u + "px;", l = "gantt_scale_cell" + (s == e.count - 1 ? " gantt_last_cell" : ""), f = i.call(this, n), f && (l += " " + f);
            var c = "<div class='" + l + "' style='" + a + "'>" + o + "</div>";
            t.push(c)
        }
    }
    return t.join("")
},gantt._render_tasks_scales = function () {
    this._init_tasks_range(), this._scroll_resize(), this._set_sizes();
    var e = "", t = 0, n = 0, r = 0;
    if (this._is_chart_visible()) {
        var i = this._scale_helpers, s = [i.primaryScale()].concat(this.config.subscales);
        r = this.config.scale_height - 1, i.sortScales(s);
        for (var o = this._get_resize_options(), u = o.x ? 0 : this.$task.offsetWidth, a = i.prepareConfigs(s, this.config.min_column_width, u, r), f = this._tasks = a[a.length - 1], l = [], c = this.templates.scale_row_class, h = 0; h < a.length; h++) {
            var p = "gantt_scale_line", d = c(a[h]);
            d && (p += " " + d), l.push('<div class="' + p + '" style="height:' + a[h].height + "px;line-height:" + a[h].height + 'px">' + this._prepare_scale_html(a[h]) + "</div>")
        }
        e = l.join(""), t = f.full_width + this.$scroll_ver.offsetWidth + "px", n = f.full_width + "px", r += "px"
    }
    this.$task.style.display = this._is_chart_visible() ? "" : "none", this.$task_scale.style.height = r, this.$task_data.style.width = this.$task_scale.style.width = t, this.$task_links.style.width = this.$task_bars.style.width = n, this.$task_scale.innerHTML = e
},gantt._render_bg_line = function (e) {
    var t = gantt._tasks, n = t.count, r = [];
    if (gantt.config.show_task_cells)for (var i = 0; n > i; i++) {
        var s = t.width[i], o = "", u = "";
        if (s > 0) {
            o = "width:" + s + "px;", u = "gantt_task_cell" + (i == n - 1 ? " gantt_last_cell" : ""), l = this.templates.task_cell_class(e, t.trace_x[i]), l && (u += " " + l);
            var a = "<div class='" + u + "' style='" + o + "'></div>";
            r.push(a)
        }
    }
    var f = e.$index % 2 !== 0, l = gantt.templates.task_row_class(e.start_date, e.end_date, e), c = "gantt_task_row" + (f ? " odd" : "") + (l ? " " + l : "");
    this.getState().selected_task == e.id && (c += " gantt_selected");
    var h = document.createElement("div");
    return h.className = c, h.style.height = gantt.config.row_height + "px", h.setAttribute(this.config.task_attribute, e.id), h.innerHTML = r.join(""), h
},gantt._adjust_scales = function () {
    if (this.config.fit_tasks) {
        var e = +this._min_date, t = +this._max_date;
        if (this._init_tasks_range(), +this._min_date != e || +this._max_date != t)return this.render(), this.callEvent("onScaleAdjusted", []), !0
    }
    return!1
},gantt.refreshTask = function (e, t) {
    var n = this._get_task_renderers(), r = this.getTask(e);
    if (r && this.isTaskVisible(e))for (var i = 0; i < n.length; i++)n[i].render_item(r); else for (var i = 0; i < n.length; i++)n[i].remove_item(e);
    if (void 0 === t || t) {
        for (var r = this.getTask(e), i = 0; i < r.$source.length; i++)gantt.refreshLink(r.$source[i]);
        for (var i = 0; i < r.$target.length; i++)gantt.refreshLink(r.$target[i])
    }
},gantt.refreshLink = function (e) {
    this.isLinkExists(e) ? gantt._render_link(e) : gantt._linkRenderer.remove_item(e)
},gantt._combine_item_class = function (e, t, n) {
    var r = [e];
    t && r.push(t);
    var i = gantt.getState(), s = this.getTask(n);
    this._get_safe_type(s.type) == this.config.types.milestone && r.push("gantt_milestone"), this._get_safe_type(s.type) == this.config.types.project && r.push("gantt_project"), this._is_flex_task(s) && r.push("gantt_dependent_task"), this.config.select_task && n == i.selected_task && r.push("gantt_selected"), n == i.drag_id && r.push("gantt_drag_" + i.drag_mode);
    var o = gantt._get_link_state();
    if (o.link_source_id == n && r.push("gantt_link_source"), o.link_target_id == n && r.push("gantt_link_target"), o.link_landing_area && o.link_target_id && o.link_source_id && o.link_target_id != o.link_source_id) {
        var u = o.link_source_id, a = o.link_source_start, f = o.link_target_start, l = gantt.isLinkAllowed(u, n, a, f), c = "";
        c = l ? f ? "link_start_allow" : "link_finish_allow" : f ? "link_start_deny" : "link_finish_deny", r.push(c)
    }
    return r.join(" ")
},gantt._render_pair = function (e, t, n, r) {
    var i = gantt.getState();
    +n.end_date <= +i.max_date && e.appendChild(r(t + " task_right")), +n.start_date >= +i.min_date && e.appendChild(r(t + " task_left"))
},gantt._get_task_height = function () {
    var e = this.config.task_height;
    return"full" == e && (e = this.config.row_height - 5), e = Math.min(e, this.config.row_height), Math.max(e, 0)
},gantt._get_milestone_width = function () {
    return this._get_task_height()
},gantt._get_visible_milestone_width = function () {
    var e = gantt._get_task_height();
    return Math.sqrt(2 * e * e)
},gantt._get_task_width = function (e) {
    return Math.round(this._get_task_pos(e, !1).x - this._get_task_pos(e, !0).x)
},gantt._render_task_element = function (e) {
    var t = this._get_task_pos(e), n = this.config, r = this._get_task_height(), i = Math.floor((this.config.row_height - r) / 2);
    e.type == n.types.milestone && n.link_line_width > 1 && (i += 1);
    var s = document.createElement("div"), o = gantt._get_task_width(e), u = this._get_safe_type(e.type);
    s.setAttribute(this.config.task_attribute, e.id), s.appendChild(gantt._render_task_content(e, o)), s.className = this._combine_item_class("gantt_task_line", this.templates.task_class(e.start_date, e.end_date, e), e.id), s.style.cssText = ["left:" + t.x + "px", "top:" + (i + t.y) + "px", "height:" + r + "px", "line-height:" + r + "px", "width:" + o + "px"].join(";");
    var a = this._render_leftside_content(e);
    return a && s.appendChild(a), a = this._render_rightside_content(e), a && s.appendChild(a), n.show_progress && u != this.config.types.milestone && this._render_task_progress(e, s, o), this.config.readonly || (n.drag_resize && !this._is_flex_task(e) && u != this.config.types.milestone && gantt._render_pair(s, "gantt_task_drag", e, function (e) {
        var t = document.createElement("div");
        return t.className = e, t
    }), n.drag_links && gantt._render_pair(s, "gantt_link_control", e, function (e) {
        var t = document.createElement("div");
        t.className = e, t.style.cssText = ["height:" + r + "px", "line-height:" + r + "px"].join(";");
        var n = document.createElement("div");
        return n.className = "gantt_link_point", t.appendChild(n), t
    })), s
},gantt._render_side_content = function (e, t, n) {
    if (!t)return null;
    var r = t(e.start_date, e.end_date, e);
    if (!r)return null;
    var i = document.createElement("div");
    return i.className = "gantt_side_content " + n, i.innerHTML = r, i
},gantt._render_leftside_content = function (e) {
    var t = "gantt_left " + gantt._get_link_crossing_css(!0, e);
    return gantt._render_side_content(e, this.templates.leftside_text, t)
},gantt._render_rightside_content = function (e) {
    var t = "gantt_right " + gantt._get_link_crossing_css(!1, e);
    return gantt._render_side_content(e, this.templates.rightside_text, t)
},gantt._get_conditions = function (e) {
    return e ? {$source: [gantt.config.links.start_to_start], $target: [gantt.config.links.start_to_start, gantt.config.links.finish_to_start]} : {$source: [gantt.config.links.finish_to_start, gantt.config.links.finish_to_finish], $target: [gantt.config.links.finish_to_finish]}
},gantt._get_link_crossing_css = function (e, t) {
    var n = gantt._get_conditions(e);
    for (var r in n)for (var i = t[r], s = 0; s < i.length; s++)for (var o = gantt.getLink(i[s]), u = 0; u < n[r].length; u++)if (o.type == n[r][u])return"gantt_link_crossing";
    return""
},gantt._render_task_content = function (e) {
    var t = document.createElement("div");
    return this._get_safe_type(e.type) != this.config.types.milestone && (t.innerHTML = this.templates.task_text(e.start_date, e.end_date, e)), t.className = "gantt_task_content", t
},gantt._render_task_progress = function (e, t, n) {
    var r = 1 * e.progress || 0;
    n = Math.max(n - 2, 0);
    var i = document.createElement("div"), s = Math.round(n * r);
    if (s = Math.min(n, s), i.style.width = s + "px", i.className = "gantt_task_progress", i.innerHTML = this.templates.progress_text(e.start_date, e.end_date, e), t.appendChild(i), this.config.drag_progress && !gantt.config.readonly) {
        var o = document.createElement("div");
        o.style.left = s + "px", o.className = "gantt_task_progress_drag", i.appendChild(o), t.appendChild(o)
    }
},gantt._get_line = function (e) {
    var t = {second: 1, minute: 60, hour: 3600, day: 86400, week: 604800, month: 2592e3, year: 31536e3};
    return t[e] || 0
},gantt._date_from_pos = function (e) {
    var t = this._tasks;
    if (0 > e || e > t.full_width)return null;
    for (var n = 0, r = 0; r + t.width[n] < e;)r += t.width[n], n++;
    var i = (e - r) / t.width[n], s = gantt._get_coll_duration(t, t.trace_x[n]), o = new Date(t.trace_x[n].valueOf() + Math.round(i * s));
    return o
},gantt.posFromDate = function (e) {
    var t = gantt._day_index_by_date(e);
    dhtmlx.assert(t >= 0, "Invalid day index");
    for (var n = Math.floor(t), r = t % 1, i = 0, s = 1; n >= s; s++)i += gantt._tasks.width[s - 1];
    return r && (i += n < gantt._tasks.width.length ? gantt._tasks.width[n] * (r % 1) : 1), i
},gantt._day_index_by_date = function (e) {
    var t = new Date(e), n = gantt._tasks.trace_x, r = gantt._tasks.ignore_x;
    if (+t <= this._min_date)return 0;
    if (+t >= this._max_date)return n.length;
    for (var i = 0; i < n.length - 1 && (!(+t < n[i + 1]) || r[+n[i + 1]]); i++);
    return i + (e - n[i]) / gantt._get_coll_duration(gantt._tasks, n[i])
},gantt._get_coll_duration = function (e, t) {
    return gantt.date.add(t, e.step, e.unit) - t
},gantt._get_x_pos = function (e, t) {
    t = t !== !1;
    gantt.posFromDate(t ? e.start_date : e.end_date)
},gantt._get_task_coord = function (e, t, n) {
    t = t !== !1, n = n || 0;
    var r = e.type == this.config.types.milestone, i = this.posFromDate(t || r ? e.start_date : e.end_date), s = this._y_from_ind(this._get_visible_order(e.id));
    return r && (t ? i -= n : i += n), {x: i, y: s}
},gantt._get_task_pos = function (e, t) {
    t = t !== !1;
    var n = gantt._get_milestone_width() / 2;
    return this._get_task_coord(e, t, n)
},gantt._get_task_visible_pos = function (e, t) {
    t = t !== !1;
    var n = gantt._get_visible_milestone_width() / 2;
    return this._get_task_coord(e, t, n)
},gantt._correct_shift = function (e, t) {
    return e -= 6e4 * ((new Date(gantt._min_date)).getTimezoneOffset() - (new Date(e)).getTimezoneOffset()) * (t ? -1 : 1)
},gantt._get_mouse_pos = function (e) {
    if (e.pageX || e.pageY)var t = {x: e.pageX, y: e.pageY};
    var n = _isIE ? document.documentElement : document.body, t = {x: e.clientX + n.scrollLeft - n.clientLeft, y: e.clientY + n.scrollTop - n.clientTop}, r = gantt._get_position(gantt.$task_data);
    return t.x = t.x - r.x + gantt.$task_data.scrollLeft, t.y = t.y - r.y + gantt.$task_data.scrollTop, t
},gantt._task_renderer = function (e, t, n, r) {
    return this._task_area_pulls || (this._task_area_pulls = {}), this._task_area_renderers || (this._task_area_renderers = {}), this._task_area_renderers[e] ? this._task_area_renderers[e] : (t || dhtmlx.assert(!1, "Invalid renderer call"), this._task_area_renderers[e] = {render_item: function (s, o) {
        var u = gantt._task_area_pulls[e];
        if (o = o || n, r && !r(s))return void this.remove_item(s.id);
        var a = t.call(gantt, s);
        a && (u[s.id] ? this.replace_item(s.id, a) : (u[s.id] = a, o.appendChild(a)))
    }, render_items: function (t, r) {
        this.rendered = gantt._task_area_pulls[e] = {}, r = r || n, r.innerHTML = "";
        for (var i = document.createDocumentFragment(), s = 0, o = t.length; o > s; s++)this.render_item(t[s], i);
        r.appendChild(i)
    }, replace_item: function (e, t) {
        var n = this.rendered[e];
        n && n.parentNode && n.parentNode.replaceChild(t, n), this.rendered[e] = t
    }, remove_item: function (e) {
        var t = this.rendered[e];
        t && t.parentNode && t.parentNode.removeChild(t), delete this.rendered[e]
    }, change_id: function (e, t) {
        this.rendered[t] = this.rendered[e], delete this.rendered[e]
    }, rendered: this._task_area_pulls[e], node: n}, this._task_area_renderers[e])
},gantt._pull = {},gantt._branches = {},gantt._order = [],gantt._lpull = {},gantt.load = function (e, t, n) {
    dhtmlx.assert(arguments.length, "Invalid load arguments"), this.callEvent("onLoadStart", []);
    var r = "json", i = null;
    arguments.length >= 3 ? (r = t, i = n) : "string" == typeof arguments[1] ? r = arguments[1] : "function" == typeof arguments[1] && (i = arguments[1]), dhtmlxAjax.get(e, dhtmlx.bind(function (e) {
        this.on_load(e, r), "function" == typeof i && i.call(this)
    }, this))
},gantt.parse = function (e, t) {
    this.on_load({xmlDoc: {responseText: e}}, t)
},gantt.serialize = function (e) {
    return e = e || "json", this[e].serialize()
},gantt.on_load = function (e, t) {
    t || (t = "json"), dhtmlx.assert(this[t], "Invalid data type:'" + t + "'");
    var n = e.xmlDoc.responseText, r = this[t].parse(n, e);
    this._process_loading(r), this.callEvent("onLoadEnd", [])
},gantt._process_loading = function (e) {
    e.collections && this._load_collections(e.collections);
    for (var t = e.data, n = 0; n < t.length; n++) {
        var r = t[n];
        this._init_task(r), this.callEvent("onTaskLoading", [r]) && (this._pull[r.id] = r, this._add_branch(r))
    }
    this._sync_order();
    for (var n in this._pull)this._pull[n].$level = this._item_level(this._pull[n]);
    this._init_links(e.links || (e.collections ? e.collections.links : []))
},gantt._init_links = function (e) {
    if (e)for (var t = 0; t < e.length; t++)if (e[t]) {
        var n = this._init_link(e[t]);
        this._lpull[n.id] = n
    }
    this._sync_links()
},gantt._load_collections = function (e) {
    var t = !1;
    for (var n in e)if (e.hasOwnProperty(n)) {
        t = !0;
        var r = e[n], i = this.serverList[n];
        if (!i)continue;
        i.splice(0, i.length);
        for (var s = 0; s < r.length; s++) {
            var o = r[s], u = dhtmlx.copy(o);
            u.key = u.value;
            for (var a in o)if (o.hasOwnProperty(a)) {
                if ("value" == a || "label" == a)continue;
                u[a] = o[a]
            }
            i.push(u)
        }
    }
    t && this.callEvent("onOptionsLoad", [])
},gantt._sync_order = function () {
    this._order = [], this._sync_order_item({parent: this.config.root_id, $open: !0, $ignore: !0, id: this.config.root_id}), this._scroll_resize(), this._set_sizes()
},gantt.attachEvent("onBeforeTaskDisplay", function (e, t) {
    return!t.$ignore
}),gantt._sync_order_item = function (e) {
    if (e.id && this._filter_task(e.id, e) && this.callEvent("onBeforeTaskDisplay", [e.id, e]) && this._order.push(e.id), e.$open) {
        var t = this._branches[e.id];
        if (t)for (var n = 0; n < t.length; n++)this._sync_order_item(this._pull[t[n]])
    }
},gantt._get_visible_order = function (e) {
    dhtmlx.assert(e, "Invalid argument");
    for (var t = this._order, n = 0, r = t.length; r > n; n++)if (t[n] == e)return n;
    return-1
},gantt.eachTask = function (e, t, n) {
    t = t || this.config.root_id, n = n || this;
    var r = this._branches[t];
    if (r)for (var i = 0; i < r.length; i++) {
        var s = this._pull[r[i]];
        e.call(n, s), this._branches[s.id] && this.eachTask(e, s.id, n)
    }
},gantt.json = {parse: function (data) {
    return dhtmlx.assert(data, "Invalid data"), "string" == typeof data && (window.JSON ? data = JSON.parse(data) : (gantt._temp = eval("(" + data + ")"), data = gantt._temp || {}, gantt._temp = null)), data.dhx_security && (dhtmlx.security_key = data.dhx_security), data
}, _copyLink: function (e) {
    var t = {};
    for (var n in e)t[n] = e[n];
    return t
}, _copyObject: function (e) {
    var t = {};
    for (var n in e)"$" != n.charAt(0) && (t[n] = e[n]);
    return t.start_date = gantt.templates.xml_format(t.start_date), t.end_date && (t.end_date = gantt.templates.xml_format(t.end_date)), t
}, serialize: function () {
    var e = [], t = [];
    gantt.eachTask(function (t) {
        e.push(this._copyObject(t))
    }, gantt.config.root_id, this);
    for (var n in gantt._lpull)t.push(this._copyLink(gantt._lpull[n]));
    return{data: e, links: t}
}},gantt.xml = {_xmlNodeToJSON: function (e, t) {
    for (var n = {}, r = 0; r < e.attributes.length; r++)n[e.attributes[r].name] = e.attributes[r].value;
    if (!t) {
        for (var r = 0; r < e.childNodes.length; r++) {
            var i = e.childNodes[r];
            1 == i.nodeType && (n[i.tagName] = i.firstChild ? i.firstChild.nodeValue : "")
        }
        n.text || (n.text = e.firstChild ? e.firstChild.nodeValue : "")
    }
    return n
}, _getCollections: function (e) {
    for (var t = {}, n = e.doXPath("//coll_options"), r = 0; r < n.length; r++)for (var i = n[r].getAttribute("for"), s = t[i] = [], o = e.doXPath(".//item", n[r]), u = 0; u < o.length; u++) {
        for (var a = o[u], f = a.attributes, l = {key: o[u].getAttribute("value"), label: o[u].getAttribute("label")}, c = 0; c < f.length; c++) {
            var h = f[c];
            "value" != h.nodeName && "label" != h.nodeName && (l[h.nodeName] = h.nodeValue)
        }
        s.push(l)
    }
    return t
}, _getXML: function (e, t, n) {
    n = n || "data", t.getXMLTopNode || (t = new dtmlXMLLoaderObject(function () {
    }), t.loadXMLString(e));
    var r = t.getXMLTopNode(n);
    if (r.tagName != n)throw"Invalid XML data";
    var i = r.getAttribute("dhx_security");
    return i && (dhtmlx.security_key = i), t
}, parse: function (e, t) {
    t = this._getXML(e, t);
    for (var n = {}, r = n.data = [], i = t.doXPath("//task"), s = 0; s < i.length; s++)r[s] = this._xmlNodeToJSON(i[s]);
    return n.collections = this._getCollections(t), n
}, _copyLink: function (e) {
    return"<item id='" + e.id + "' source='" + e.source + "' target='" + e.target + "' type='" + e.type + "' />"
}, _copyObject: function (e) {
    var t = gantt.templates.xml_format(e.start_date), n = gantt.templates.xml_format(e.end_date);
    return"<task id='" + e.id + "' parent='" + (e.parent || "") + "' start_date='" + t + "' duration='" + e.duration + "' open='" + !!e.open + "' progress='" + e.progress + "' end_date='" + n + "'><![CDATA[" + e.text + "]]></task>"
}, serialize: function () {
    var e = [], t = [];
    gantt.eachTask(function (t) {
        e.push(this._copyObject(t))
    }, this.config.root_id, this);
    for (var n in gantt._lpull)t.push(this._copyLink(gantt._lpull[n]));
    return"<data>" + e.join("") + "<coll_options for='links'>" + t.join("") + "</coll_options></data>"
}},gantt.oldxml = {parse: function (e, t) {
    t = gantt.xml._getXML(e, t, "projects");
    for (var n = {collections: {links: []}}, r = n.data = [], i = t.doXPath("//task"), s = 0; s < i.length; s++) {
        r[s] = gantt.xml._xmlNodeToJSON(i[s]);
        var o = i[s].parentNode;
        r[s].parent = "project" == o.tagName ? "project-" + o.getAttribute("id") : o.parentNode.getAttribute("id")
    }
    i = t.doXPath("//project");
    for (var s = 0; s < i.length; s++) {
        var u = gantt.xml._xmlNodeToJSON(i[s], !0);
        u.id = "project-" + u.id, r.push(u)
    }
    for (var s = 0; s < r.length; s++) {
        var u = r[s];
        u.start_date = u.startdate || u.est, u.end_date = u.enddate, u.text = u.name, u.duration = u.duration / 8, u.open = 1, u.duration || u.end_date || (u.duration = 1), u.predecessortasks && n.collections.links.push({target: u.id, source: u.predecessortasks, type: gantt.config.links.finish_to_start})
    }
    return n
}, serialize: function () {
    dhtmlx.message("Serialization to 'old XML' is not implemented")
}},gantt.serverList = function (e, t) {
    return t ? this.serverList[e] = t.slice(0) : this.serverList[e] || (this.serverList[e] = []), this.serverList[e]
},gantt._working_time_helper = {units: ["year", "month", "week", "day", "hour", "minute"], hours: [8, 17], dates: {0: !1, 6: !1}, _get_unit_order: function (e) {
    for (var t = 0, n = this.units.length; n > t; t++)if (this.units[t] == e)return t;
    dhtmlx.assert(!1, "Incorrect duration unit")
}, _timestamp: function (e) {
    var t = null;
    return e.day || 0 === e.day ? t = e.day : e.date && (t = gantt.date.date_part(new Date(e.date)).valueOf()), t
}, set_time: function (e) {
    var t = void 0 !== e.hours ? e.hours : !0, n = this._timestamp(e);
    null !== n ? this.dates[n] = t : this.hours = t
}, unset_time: function (e) {
    if (e) {
        var t = this._timestamp(e);
        null !== t && delete this.dates[t]
    } else this.hours = []
}, is_working_unit: function (e, t, n) {
    return gantt.config.work_time ? (void 0 === n && (n = this._get_unit_order(t)), void 0 === n ? !1 : n && !this.is_working_unit(e, this.units[n - 1], n - 1) ? !1 : this["is_work_" + t] ? this["is_work_" + t](e) : !0) : !0
}, is_work_day: function (e) {
    var t = this.get_working_hours(e);
    return t instanceof Array ? t.length > 0 : !1
}, is_work_hour: function (e) {
    for (var t = this.get_working_hours(e), n = e.getHours(), r = 0; r < t.length; r += 2) {
        if (void 0 === t[r + 1])return t[r] == n;
        if (n >= t[r] && n < t[r + 1])return!0
    }
    return!1
}, get_working_hours: function (e) {
    var t = this._timestamp({date: e}), n = !0;
    return void 0 !== this.dates[t] ? n = this.dates[t] : void 0 !== this.dates[e.getDay()] && (n = this.dates[e.getDay()]), n === !0 ? this.hours : n ? n : []
}, get_work_units_between: function (e, t, n, r) {
    if (!n)return!1;
    for (var i = new Date(e), s = new Date(t), r = r || 1, o = 0; i.valueOf() < s.valueOf();)this.is_working_unit(i, n) && o++, i = gantt.date.add(i, r, n);
    return o
}, add_worktime: function (e, t, n, r) {
    if (!n)return!1;
    for (var i = new Date(e), s = 0, r = r || 1, t = 1 * t; t > s;) {
        var o = gantt.date.add(i, r, n);
        this.is_working_unit(r > 0 ? i : o, n) && s++, i = o
    }
    return i
}, get_closest_worktime: function (e) {
    if (this.is_working_unit(e.date, e.unit))return e.date;
    var t = e.unit, n = gantt.date[t + "_start"](e.date), r = new Date(n), i = new Date(n), s = !0, o = 3e3, u = 0, a = "any" == e.dir || !e.dir, f = 1;
    for ("past" == e.dir && (f = -1); !this.is_working_unit(n, t);)if (a && (n = s ? r : i, f = -1 * f), n = gantt.date.add(n, f, t), a && (s ? r = n : i = n), s = !s, u++, u > o)return dhtmlx.assert(!1, "Invalid working time check"), !1;
    return(n == i || "past" == e.dir) && (n = gantt.date.add(n, 1, t)), n
}},gantt.getTask = function (e) {
    return dhtmlx.assert(this._pull[e]), this._pull[e]
},gantt.getTaskByTime = function (e, t) {
    var n = this._pull, r = [];
    if (e || t) {
        e = +e || -1 / 0, t = +t || 1 / 0;
        for (var i in n) {
            var s = n[i];
            +s.start_date < t && +s.end_date > e && r.push(s)
        }
    } else for (var i in n)r.push(n[i]);
    return r
},gantt.isTaskExists = function (e) {
    return dhtmlx.defined(this._pull[e])
},gantt.isTaskVisible = function (e) {
    if (!this._pull[e])return!1;
    if (!(+this._pull[e].start_date < +this._max_date && +this._pull[e].end_date > +this._min_date))return!1;
    for (var t = 0, n = this._order.length; n > t; t++)if (this._order[t] == e)return!0;
    return!1
},gantt.updateTask = function (e, t) {
    return dhtmlx.defined(t) || (t = this.getTask(e)), this.callEvent("onBeforeTaskUpdate", [e, t]) === !1 ? !1 : (this._pull[t.id] = t, this._is_parent_sync(t) || this._resync_parent(t), this._update_parents(t.id), this.refreshTask(t.id), this.callEvent("onAfterTaskUpdate", [e, t]), this._sync_order(), void this._adjust_scales())
},gantt._add_branch = function (e) {
    this._branches[e.parent] || (this._branches[e.parent] = []);
    for (var t = this._branches[e.parent], n = !1, r = 0, i = t.length; i > r; r++)if (t[r] == e.id) {
        n = !0;
        break
    }
    n || t.push(e.id), this._sync_parent(e), this._sync_order()
},gantt._move_branch = function (e, t, n) {
    e.parent = n, this._sync_parent(e), this._replace_branch_child(t, e.id), n ? this._add_branch(e) : delete this._branches[e.id], e.$level = this._item_level(e), this._sync_order()
},gantt._resync_parent = function (e) {
    this._move_branch(e, e.$rendered_parent, e.parent)
},gantt._sync_parent = function (e) {
    e.$rendered_parent = e.parent
},gantt._is_parent_sync = function (e) {
    return e.$rendered_parent == e.parent
},gantt._replace_branch_child = function (e, t, n) {
    var r = this._branches[e];
    if (r) {
        for (var i = [], s = 0; s < r.length; s++)r[s] != t ? i.push(r[s]) : n && i.push(n);
        this._branches[e] = i
    }
    this._sync_order()
},gantt.addTask = function (e, t) {
    return dhtmlx.defined(t) || (t = e.parent || 0), dhtmlx.defined(this._pull[t]) || (t = 0), e.parent = t, e = this._init_task(e), this.callEvent("onBeforeTaskAdd", [e.id, e]) === !1 ? !1 : (this._pull[e.id] = e, this._add_branch(e), this.refreshData(), this.callEvent("onAfterTaskAdd", [e.id, e]), this._adjust_scales(), e.id)
},gantt.deleteTask = function (e) {
    return this._deleteTask(e)
},gantt._deleteTask = function (e, t) {
    var n = this.getTask(e);
    if (!t && this.callEvent("onBeforeTaskDelete", [e, n]) === !1)return!1;
    !t && this._dp && this._dp.setUpdateMode("off");
    var r = this._branches[n.id] || [];
    this._update_flags(e, !1);
    for (var i = 0; i < r.length; i++)this._silentStart(), this._deleteTask(r[i], !0), this._dp && (this._dp._ganttMode = "tasks", this._dp.setUpdated(r[i], !0, "deleted")), this._silentEnd();
    for (!t && this._dp && this._dp.setUpdateMode("cell"); n.$source.length > 0;)this.deleteLink(n.$source[0]);
    for (; n.$target.length > 0;)this.deleteLink(n.$target[0]);
    return delete this._pull[e], this._move_branch(n, n.parent, null), t || (this.callEvent("onAfterTaskDelete", [e, n]), this.refreshData()), !0
},gantt.clearAll = function () {
    this._pull = {}, this._branches = {}, this._order = [], this._order_full = [], this._lpull = {}, this.refreshData(), this.callEvent("onClear", [])
},gantt._update_flags = function (e, t) {
    this._lightbox_id == e && (this._lightbox_id = t), this._selected_task == e && (this._selected_task = t), this._tasks_dnd.drag && this._tasks_dnd.drag.id == e && (this._tasks_dnd.drag.id = t)
},gantt.changeTaskId = function (e, t) {
    var n = this._pull[t] = this._pull[e];
    this._pull[t].id = t, delete this._pull[e];
    for (var r in this._pull)this._pull[r].parent == e && (this._pull[r].parent = t);
    this._update_flags(e, t), this._replace_branch_child(n.parent, e, t), this.callEvent("onTaskIdChange", [e, t])
},gantt._get_duration_unit = function () {
    return 1e3 * gantt._get_line(this.config.duration_unit) || this.config.duration_unit
},gantt._get_safe_type = function (e) {
    for (var t in this.config.types)if (this.config.types[t] == e)return e;
    return gantt.config.types.task
},gantt._get_type_name = function (e) {
    for (var t in this.config.types)if (this.config.types[t] == e)return t;
    return"task"
},gantt.getWorkHours = function (e) {
    return this._working_time_helper.get_working_hours(e)
},gantt.setWorkTime = function (e) {
    this._working_time_helper.set_time(e)
},gantt.isWorkTime = function (e, t) {
    var n = this._working_time_helper;
    return n.is_working_unit(e, t || this.config.duration_unit)
},gantt.getClosestWorkTime = function (e) {
    var t = this._working_time_helper;
    return e instanceof Date && (e = {date: e}), e.dir = e.dir || "any", e.unit = e.unit || this.config.duration_unit, t.get_closest_worktime(e)
},gantt.calculateDuration = function (e, t) {
    var n = this._working_time_helper;
    return n.get_work_units_between(e, t, this.config.duration_unit, this.config.duration_step)
},gantt.calculateEndDate = function (e, t) {
    var n = this._working_time_helper, r = t >= 0 ? 1 : -1;
    return n.add_worktime(e, Math.abs(t), this.config.duration_unit, r * this.config.duration_step)
},gantt._init_task = function (e) {
    return dhtmlx.defined(e.id) || (e.id = dhtmlx.uid()), e.start_date && (e.start_date = gantt.date.parseDate(e.start_date, "xml_date")), e.end_date && (e.end_date = gantt.date.parseDate(e.end_date, "xml_date")), e.start_date && !e.end_date && e.duration && (e.end_date = this.calculateEndDate(e.start_date, e.duration)), gantt.config.work_time && gantt.config.correct_work_time && (e.start_date && (e.start_date = gantt.getClosestWorkTime(e.start_date)), e.end_date && (e.end_date = gantt.getClosestWorkTime(e.end_date))), gantt._init_task_timing(e), e.$source = [], e.$target = [], e.parent = e.parent || this.config.root_id, e.$open = dhtmlx.defined(e.open) ? e.open : !1, e.$level = this._item_level(e), e
},gantt._init_task_timing = function (e) {
    void 0 === e.$rendered_type ? e.$rendered_type = e.type : e.$rendered_type != e.type && (delete e.$no_end, delete e.$no_start, e.$rendered_type = e.type), void 0 !== e.$no_end && void 0 !== e.$no_start || e.type == this.config.types.milestone || (e.type == this.config.types.project ? e.$no_end = e.$no_start = !0 : (e.$no_end = !(e.end_date || e.duration), e.$no_start = !e.start_date)), e.type == this.config.types.milestone && (e.end_date = e.start_date), e.start_date && e.end_date && (e.duration = this.calculateDuration(e.start_date, e.end_date)), e.duration = e.duration || 0
},gantt._is_flex_task = function (e) {
    return!(!e.$no_end && !e.$no_start)
},gantt._update_parents = function (e, t) {
    if (e) {
        for (var n = this.getTask(e); !n.$no_end && !n.$no_start && n.parent && this.isTaskExists(n.parent);)n = this.getTask(n.parent);
        if (n.$no_end) {
            var r = 0;
            this.eachTask(function (e) {
                e.end_date && +e.end_date > +r && (r = new Date(e.end_date))
            }, n.id), r && (n.end_date = r)
        }
        if (n.$no_start) {
            var i = 1 / 0;
            this.eachTask(function (e) {
                e.start_date && +e.start_date < +i && (i = new Date(e.start_date))
            }, n.id), 1 / 0 != i && (n.start_date = i)
        }
        (n.$no_end || n.$no_start) && (this._init_task_timing(n), t || this.refreshTask(n.id, !0)), n.parent && this.isTaskExists(n.parent) && this._update_parents(n.parent, t)
    }
},gantt.isChildOf = function (e, t) {
    if (!this.isTaskExists(e))return!1;
    if (t === this.config.root_id)return this.isTaskExists(e);
    for (var n = this.getTask(e); n && this.isTaskExists(n.parent);)if (n = this.getTask(n.parent), n && n.id == t)return!0;
    return!1
},gantt._get_closest_date = function (e) {
    for (var t = e.date, n = e.step, r = e.unit, i = gantt.date[r + "_start"](new Date(this._min_date)); +t > +i;)i = gantt.date.add(i, n, r);
    var s = gantt.date.add(i, -1 * n, r);
    return e.dir && "future" == e.dir ? i : e.dir && "past" == e.dir ? s : Math.abs(t - s) < Math.abs(i - t) ? s : i
},gantt.attachEvent("onBeforeTaskUpdate", function (e, t) {
    return gantt._init_task_timing(t), !0
}),gantt.attachEvent("onBeforeTaskAdd", function (e, t) {
    return gantt._init_task_timing(t), !0
}),gantt._item_level = function (e) {
    for (var t = 0; e.parent && dhtmlx.defined(this._pull[e.parent]);)e = this._pull[e.parent], t++;
    return t
},gantt.sort = function (e, t, n) {
    var r = !arguments[3];
    dhtmlx.defined(n) || (n = this.config.root_id), dhtmlx.defined(e) || (e = "order");
    var i = "string" == typeof e ? function (n, r) {
        var i = n[e] > r[e];
        return t && (i = !i), i ? 1 : -1
    } : e, s = this._branches[n];
    if (s) {
        for (var o = [], u = s.length - 1; u >= 0; u--)o[u] = this._pull[s[u]];
        o.sort(i);
        for (var u = 0; u < o.length; u++)s[u] = o[u].id, this.sort(e, t, s[u], !0)
    }
    r && this.refreshData()
},gantt.getNext = function (e) {
    for (var t = 0; t < this._order.length - 1; t++)if (this._order[t] == e)return this._order[t + 1];
    return null
},gantt.getPrev = function (e) {
    for (var t = 1; t < this._order.length; t++)if (this._order[t] == e)return this._order[t - 1];
    return null
},gantt._dp_init = function (e) {
    e.setTransactionMode("POST", !0), e.serverProcessor += (-1 != e.serverProcessor.indexOf("?") ? "&" : "?") + "editing=true", e._serverProcessor = e.serverProcessor, e.styles = {updated: "gantt_updated", inserted: "gantt_inserted", deleted: "gantt_deleted", invalid: "gantt_invalid", error: "gantt_error", clear: ""}, e._methods = ["_row_style", "setCellTextStyle", "_change_id", "_delete_task"], this.attachEvent("onAfterTaskAdd", function (n) {
        e._ganttMode = "tasks", e.setUpdated(n, !0, "inserted")
    }), this.attachEvent("onAfterTaskUpdate", function (n) {
        e._ganttMode = "tasks", e.setUpdated(n, !0)
    }), this.attachEvent("onAfterTaskDelete", function (n) {
        e._ganttMode = "tasks", e.setUpdated(n, !0, "deleted")
    }), this.attachEvent("onAfterLinkUpdate", function (n) {
        e._ganttMode = "links", e.setUpdated(n, !0)
    }), this.attachEvent("onAfterLinkAdd", function (n) {
        e._ganttMode = "links", e.setUpdated(n, !0, "inserted")
    }), this.attachEvent("onAfterLinkDelete", function (n) {
        e._ganttMode = "links", e.setUpdated(n, !0, "deleted")
    }), this.attachEvent("onRowDragEnd", function (n, r) {
        e._ganttMode = "tasks", this.getTask(n).target = r, e.setUpdated(n, !0, "order")
    }), e.attachEvent("onBeforeDataSending", function () {
        return this.serverProcessor = this._serverProcessor + getUrlSymbol(this._serverProcessor) + "gantt_mode=" + this._ganttMode, !0
    }), e._getRowData = dhtmlx.bind(function (n) {
        var r;
        r = "tasks" == e._ganttMode ? this.isTaskExists(n) ? this.getTask(n) : {id: n} : this.isLinkExists(n) ? this.getLink(n) : {id: n};
        var i = {};
        for (var s in r)if ("$" != s.substr(0, 1)) {
            var o = r[s];
            i[s] = o instanceof Date ? this.templates.xml_format(o) : o
        }
        return r.$no_start && (r.start_date = "", r.duration = ""), r.$no_end && (r.end_date = "", r.duration = ""), i[e.action_param] = this.getUserData(n, e.action_param), i
    }, this), this._change_id = dhtmlx.bind(function (n, r) {
        "tasks" != e._ganttMode ? this.changeLinkId(n, r) : this.changeTaskId(n, r)
    }, this), this._row_style = function (n, r) {
        if ("tasks" == e._ganttMode) {
            var i = gantt.getTaskRowNode(n);
            if (i)if (r)i.className += " " + r; else {
                var s = / (gantt_updated|gantt_inserted|gantt_deleted|gantt_invalid|gantt_error)/g;
                i.className = i.className.replace(s, "")
            }
        }
    }, this._delete_task = function () {
    }, this._dp = e
},gantt.getUserData = function (e, t) {
    return this.userdata || (this.userdata = {}), this.userdata[e] && this.userdata[e][t] ? this.userdata[e][t] : ""
},gantt.setUserData = function (e, t, n) {
    this.userdata || (this.userdata = {}), this.userdata[e] || (this.userdata[e] = {}), this.userdata[e][t] = n
},gantt._init_link = function (e) {
    return dhtmlx.defined(e.id) || (e.id = dhtmlx.uid()), e
},gantt._sync_links = function () {
    for (var e in this._pull)this._pull[e].$source = [], this._pull[e].$target = [];
    for (var e in this._lpull) {
        var t = this._lpull[e];
        this._pull[t.source] && this._pull[t.source].$source.push(e), this._pull[t.target] && this._pull[t.target].$target.push(e)
    }
},gantt.getLink = function (e) {
    return dhtmlx.assert(this._lpull[e], "Link doesn't exist"), this._lpull[e]
},gantt.isLinkExists = function (e) {
    return dhtmlx.defined(this._lpull[e])
},gantt.addLink = function (e) {
    return e = this._init_link(e), this.callEvent("onBeforeLinkAdd", [e.id, e]) === !1 ? !1 : (this._lpull[e.id] = e, this._sync_links(), this._render_link(e.id), this.callEvent("onAfterLinkAdd", [e.id, e]), e.id)
},gantt.updateLink = function (e, t) {
    return dhtmlx.defined(t) || (t = this.getLink(e)), this.callEvent("onBeforeLinkUpdate", [e, t]) === !1 ? !1 : (this._lpull[e] = t, this._sync_links(), this._render_link(e), this.callEvent("onAfterLinkUpdate", [e, t]), !0)
},gantt.deleteLink = function (e) {
    return this._deleteLink(e)
},gantt._deleteLink = function (e, t) {
    var n = this.getLink(e);
    return t || this.callEvent("onBeforeLinkDelete", [e, n]) !== !1 ? (delete this._lpull[e], this._sync_links(), this.refreshLink(e), t || this.callEvent("onAfterLinkDelete", [e, n]), !0) : !1
},gantt.changeLinkId = function (e, t) {
    this._lpull[t] = this._lpull[e], this._lpull[t].id = t, delete this._lpull[e], this._sync_links(), this.callEvent("onLinkIdChange", [e, t])
},gantt.getChildren = function (e) {
    return dhtmlx.defined(this._branches[e]) ? this._branches[e] : []
},gantt.hasChild = function (e) {
    return dhtmlx.defined(this._branches[e])
},gantt.refreshData = function () {
    this._sync_order(), this._render_data()
},gantt._configure = function (e, t) {
    for (var n in t)"undefined" == typeof e[n] && (e[n] = t[n])
},gantt._init_skin = function () {
    if (!gantt.skin)for (var e = document.getElementsByTagName("link"), t = 0; t < e.length; t++) {
        var n = e[t].href.match("dhtmlxgantt_([a-z]+).css");
        if (n) {
            gantt.skin = n[1];
            break
        }
    }
    gantt.skin || (gantt.skin = "terrace");
    var r = gantt.skins[gantt.skin];
    this._configure(gantt.config, r.config);
    var i = gantt.config.columns;
    i[1] && "undefined" == typeof i[1].width && (i[1].width = r._second_column_width), i[2] && "undefined" == typeof i[2].width && (i[2].width = r._third_column_width), r._lightbox_template && (gantt._lightbox_template = r._lightbox_template), gantt._init_skin = function () {
    }
},gantt.skins = {},gantt._lightbox_methods = {},gantt._lightbox_template = "<div class='dhx_cal_ltitle'><span class='dhx_mark'>&nbsp;</span><span class='dhx_time'></span><span class='dhx_title'></span></div><div class='dhx_cal_larea'></div>",gantt.showLightbox = function (e) {
    if (e && !this.config.readonly && this.callEvent("onBeforeLightbox", [e])) {
        var t = this.getTask(e), n = this.getLightbox(this._get_safe_type(t.type));
        this._center_lightbox(n), this.showCover(), this._fill_lightbox(e, n), this.callEvent("onLightbox", [e])
    }
},gantt._get_timepicker_step = function () {
    if (this.config.round_dnd_dates) {
        var e = gantt._tasks, t = this._get_line(e.unit) * e.step / 60;
        return t >= 1440 && (t = this.config.time_step), t
    }
    return this.config.time_step
},gantt.getLabel = function (e, t) {
    for (var n = this._get_typed_lightbox_config(), r = 0; r < n.length; r++)if (n[r].map_to == e)for (var i = n[r].options, s = 0; s < i.length; s++)if (i[s].key == t)return i[s].label;
    return""
},gantt.updateCollection = function (e, t) {
    var t = t.slice(0), n = gantt.serverList(e);
    return n ? (n.splice(0, n.length), n.push.apply(n, t || []), void gantt.resetLightbox()) : !1
},gantt.getLightboxType = function () {
    return this._get_safe_type(this._lightbox_type)
},gantt.getLightbox = function (e) {
    if (void 0 === e && (e = this.getLightboxType()), !this._lightbox || this.getLightboxType() != this._get_safe_type(e)) {
        this._lightbox_type = this._get_safe_type(e);
        var t = document.createElement("DIV");
        t.className = "dhx_cal_light";
        var n = this._is_lightbox_timepicker();
        (gantt.config.wide_form || n) && (t.className += " dhx_cal_light_wide"), n && (gantt.config.wide_form = !0, t.className += " dhx_cal_light_full"), t.style.visibility = "hidden";
        var r = this._lightbox_template, i = this.config.buttons_left;
        for (var s in i)r += "<div class='dhx_btn_set dhx_left_btn_set " + i[s] + "_set'><div dhx_button='1' class='" + i[s] + "'></div><div>" + this.locale.labels[i[s]] + "</div></div>";
        i = this.config.buttons_right;
        for (var s in i)r += "<div class='dhx_btn_set dhx_right_btn_set " + i[s] + "_set' style='float:right;'><div dhx_button='1' class='" + i[s] + "'></div><div>" + this.locale.labels[i[s]] + "</div></div>";
        r += "</div>", t.innerHTML = r, gantt.config.drag_lightbox && (t.firstChild.onmousedown = gantt._ready_to_dnd, t.firstChild.onselectstart = function () {
            return!1
        }, t.firstChild.style.cursor = "pointer", gantt._init_dnd_events()), document.body.insertBefore(t, document.body.firstChild), this._lightbox = t;
        var o = this._get_typed_lightbox_config(e);
        r = this._render_sections(o);
        for (var u = t.getElementsByTagName("div"), s = 0; s < u.length; s++) {
            var a = u[s];
            if ("dhx_cal_larea" == a.className) {
                a.innerHTML = r;
                break
            }
        }
        this.resizeLightbox(), this._init_lightbox_events(this), t.style.display = "none", t.style.visibility = "visible"
    }
    return this._lightbox
},gantt._render_sections = function (e) {
    for (var t = "", n = 0; n < e.length; n++) {
        var r = this.form_blocks[e[n].type];
        if (r) {
            e[n].id = "area_" + dhtmlx.uid();
            var i = e[n].hidden ? " style='display:none'" : "", s = "";
            e[n].button && (s = "<div class='dhx_custom_button' index='" + n + "'><div class='dhx_custom_button_" + e[n].button + "'></div><div>" + this.locale.labels["button_" + e[n].button] + "</div></div>"), this.config.wide_form && (t += "<div class='dhx_wrap_section' " + i + ">"), t += "<div id='" + e[n].id + "' class='dhx_cal_lsection'>" + s + this.locale.labels["section_" + e[n].name] + "</div>" + r.render.call(this, e[n]), t += "</div>"
        }
    }
    return t
},gantt.resizeLightbox = function () {
    var e = this._lightbox;
    if (e) {
        var t = e.childNodes[1];
        t.style.height = "0px", t.style.height = t.scrollHeight + "px", e.style.height = t.scrollHeight + this.config.lightbox_additional_height + "px", t.style.height = t.scrollHeight + "px"
    }
},gantt._center_lightbox = function (e) {
    if (e) {
        e.style.display = "block";
        var t = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop, n = window.pageXOffset || document.body.scrollLeft || document.documentElement.scrollLeft, r = window.innerHeight || document.documentElement.clientHeight;
        e.style.top = t ? Math.round(t + Math.max((r - e.offsetHeight) / 2, 0)) + "px" : Math.round(Math.max((r - e.offsetHeight) / 2, 0) + 9) + "px", e.style.left = document.documentElement.scrollWidth > document.body.offsetWidth ? Math.round(n + (document.body.offsetWidth - e.offsetWidth) / 2) + "px" : Math.round((document.body.offsetWidth - e.offsetWidth) / 2) + "px"
    }
},gantt.showCover = function () {
    if (!this._cover) {
        this._cover = document.createElement("DIV"), this._cover.className = "dhx_cal_cover";
        var e = void 0 !== document.height ? document.height : document.body.offsetHeight, t = document.documentElement ? document.documentElement.scrollHeight : 0;
        this._cover.style.height = Math.max(e, t) + "px", document.body.appendChild(this._cover)
    }
},gantt._init_lightbox_events = function () {
    gantt.lightbox_events = {}, gantt.lightbox_events.dhx_save_btn = function () {
        gantt._save_lightbox()
    }, gantt.lightbox_events.dhx_delete_btn = function () {
        gantt.callEvent("onLightboxDelete", [gantt._lightbox_id]) && gantt.$click.buttons["delete"](gantt._lightbox_id)
    }, gantt.lightbox_events.dhx_cancel_btn = function () {
        gantt._cancel_lightbox()
    }, gantt.lightbox_events["default"] = function (e, t) {
        if (t.getAttribute("dhx_button"))gantt.callEvent("onLightboxButton", [t.className, t, e]); else {
            var n, r, i;
            -1 != t.className.indexOf("dhx_custom_button") && (-1 != t.className.indexOf("dhx_custom_button_") ? (n = t.parentNode.getAttribute("index"), i = t.parentNode.parentNode) : (n = t.getAttribute("index"), i = t.parentNode, t = t.firstChild));
            var s = gantt._get_typed_lightbox_config();
            n && (r = gantt.form_blocks[s[n].type], r.button_click(n, t, i, i.nextSibling))
        }
    }, dhtmlxEvent(gantt.getLightbox(), "click", function (e) {
        e = e || window.event;
        var t = e.target ? e.target : e.srcElement;
        if (t.className || (t = t.previousSibling), t && t.className && 0 === t.className.indexOf("dhx_btn_set") && (t = t.firstChild), t && t.className) {
            var n = dhtmlx.defined(gantt.lightbox_events[t.className]) ? gantt.lightbox_events[t.className] : gantt.lightbox_events["default"];
            return n(e, t)
        }
        return!1
    }), gantt.getLightbox().onkeydown = function (e) {
        switch ((e || event).keyCode) {
            case gantt.keys.edit_save:
                if ((e || event).shiftKey)return;
                gantt._save_lightbox();
                break;
            case gantt.keys.edit_cancel:
                gantt._cancel_lightbox()
        }
    }
},gantt._cancel_lightbox = function () {
    var e = this.getLightboxValues();
    this.callEvent("onLightboxCancel", [this._lightbox_id, e.$new]), e.$new && (this._deleteTask(e.id, !0), this.refreshData()), this.hideLightbox()
},gantt._save_lightbox = function () {
    var e = this.getLightboxValues();
    this.callEvent("onLightboxSave", [this._lightbox_id, e, !!e.$new]) && (e.$new ? (delete e.$new, this.addTask(e)) : (dhtmlx.mixin(this.getTask(e.id), e, !0), this.updateTask(e.id)), this.refreshData(), this.hideLightbox())
},gantt.getLightboxValues = function () {
    for (var e = dhtmlx.mixin({}, this.getTask(this._lightbox_id)), t = this._get_typed_lightbox_config(), n = 0; n < t.length; n++) {
        var r = document.getElementById(t[n].id);
        r = r ? r.nextSibling : r;
        var i = this.form_blocks[t[n].type], s = i.get_value.call(this, r, e, t[n]);
        "auto" != t[n].map_to && (e[t[n].map_to] = s)
    }
    return e
},gantt.hideLightbox = function () {
    var e = this.getLightbox();
    e && (e.style.display = "none"), this._lightbox_id = null, this.hideCover(), this.callEvent("onAfterLightbox", [])
},gantt.hideCover = function () {
    this._cover && this._cover.parentNode.removeChild(this._cover), this._cover = null
},gantt.resetLightbox = function () {
    gantt._lightbox && !gantt._custom_lightbox && gantt._lightbox.parentNode.removeChild(gantt._lightbox), gantt._lightbox = null
},gantt._set_lightbox_values = function (e, t) {
    var n = e, r = t.getElementsByTagName("span");
    gantt.templates.lightbox_header ? (r[1].innerHTML = "", r[2].innerHTML = gantt.templates.lightbox_header(n.start_date, n.end_date, n)) : (r[1].innerHTML = this.templates.task_time(n.start_date, n.end_date, n), r[2].innerHTML = (this.templates.task_text(n.start_date, n.end_date, n) || "").substr(0, 70));
    for (var i = this._get_typed_lightbox_config(this.getLightboxType()), s = 0; s < i.length; s++) {
        var o = i[s];
        if (this.form_blocks[o.type]) {
            var u = document.getElementById(o.id).nextSibling, a = this.form_blocks[o.type], f = dhtmlx.defined(n[o.map_to]) ? n[o.map_to] : o.default_value;
            a.set_value.call(this, u, f, n, o), o.focus && a.focus.call(this, u)
        }
    }
    e.id && (gantt._lightbox_id = e.id)
},gantt._fill_lightbox = function (e, t) {
    var n = this.getTask(e);
    this._set_lightbox_values(n, t)
},gantt.getLightboxSection = function (e) {
    var t = this._get_typed_lightbox_config(), n = 0;
    for (n; n < t.length && t[n].name != e; n++);
    var r = t[n];
    this._lightbox || this.getLightbox();
    var i = document.getElementById(r.id), s = i.nextSibling, o = {section: r, header: i, node: s, getValue: function (e) {
        return this.form_blocks[r.type].get_value(s, e || {}, r)
    }, setValue: function (e, t) {
        return this.form_blocks[r.type].set_value(s, e, t || {}, r)
    }}, u = this._lightbox_methods["get_" + r.type + "_control"];
    return u ? u(o) : o
},gantt._lightbox_methods.get_template_control = function (e) {
    return e.control = e.node, e
},gantt._lightbox_methods.get_select_control = function (e) {
    return e.control = e.node.getElementsByTagName("select")[0], e
},gantt._lightbox_methods.get_textarea_control = function (e) {
    return e.control = e.node.getElementsByTagName("textarea")[0], e
},gantt._lightbox_methods.get_time_control = function (e) {
    return e.control = e.node.getElementsByTagName("select"), e
},gantt._init_dnd_events = function () {
    dhtmlxEvent(document.body, "mousemove", gantt._move_while_dnd), dhtmlxEvent(document.body, "mouseup", gantt._finish_dnd), gantt._init_dnd_events = function () {
    }
},gantt._move_while_dnd = function (e) {
    if (gantt._dnd_start_lb) {
        document.dhx_unselectable || (document.body.className += " dhx_unselectable", document.dhx_unselectable = !0);
        var t = gantt.getLightbox(), n = e && e.target ? [e.pageX, e.pageY] : [event.clientX, event.clientY];
        t.style.top = gantt._lb_start[1] + n[1] - gantt._dnd_start_lb[1] + "px", t.style.left = gantt._lb_start[0] + n[0] - gantt._dnd_start_lb[0] + "px"
    }
},gantt._ready_to_dnd = function (e) {
    var t = gantt.getLightbox();
    gantt._lb_start = [parseInt(t.style.left, 10), parseInt(t.style.top, 10)], gantt._dnd_start_lb = e && e.target ? [e.pageX, e.pageY] : [event.clientX, event.clientY]
},gantt._finish_dnd = function () {
    gantt._lb_start && (gantt._lb_start = gantt._dnd_start_lb = !1, document.body.className = document.body.className.replace(" dhx_unselectable", ""), document.dhx_unselectable = !1)
},gantt._focus = function (e, t) {
    e && e.focus && (gantt.config.touch || (t && e.select && e.select(), e.focus()))
},gantt.form_blocks = {getTimePicker: function (e, t) {
    var n = e.time_format;
    if (!n) {
        var n = ["%d", "%m", "%Y"];
        gantt._get_line(gantt._tasks.unit) < gantt._get_line("day") && n.push("%H:%i")
    }
    e._time_format_order = {size: 0};
    var r = this.config, i = this.date.date_part(new Date(gantt._min_date.valueOf())), s = 1440, o = 0;
    gantt.config.limit_time_select && (s = 60 * r.last_hour + 1, o = 60 * r.first_hour, i.setHours(r.first_hour));
    for (var u = "", a = 0; a < n.length; a++) {
        var f = n[a];
        a > 0 && (u += " ");
        var l = "";
        switch (f) {
            case"%Y":
                e._time_format_order[2] = a, e._time_format_order.size++;
                for (var c = i.getFullYear() - 5, h = 0; 10 > h; h++)l += "<option value='" + (c + h) + "'>" + (c + h) + "</option>";
                break;
            case"%m":
                e._time_format_order[1] = a, e._time_format_order.size++;
                for (var h = 0; 12 > h; h++)l += "<option value='" + h + "'>" + this.locale.date.month_full[h] + "</option>";
                break;
            case"%d":
                e._time_format_order[0] = a, e._time_format_order.size++;
                for (var h = 1; 32 > h; h++)l += "<option value='" + h + "'>" + h + "</option>";
                break;
            case"%H:%i":
                var s = 1440, o = 0;
                e._time_format_order[3] = a, e._time_format_order.size++;
                var h = o, p = i.getDate();
                for (e._time_values = []; s > h;) {
                    var d = this.templates.time_picker(i);
                    l += "<option value='" + h + "'>" + d + "</option>", e._time_values.push(h), i.setTime(i.valueOf() + 60 * this._get_timepicker_step() * 1e3);
                    var v = i.getDate() != p ? 1 : 0;
                    h = 24 * v * 60 + 60 * i.getHours() + i.getMinutes()
                }
        }
        if (l) {
            var m = e.readonly ? "disabled='disabled'" : "", g = t ? " style='display:none'" : "";
            u += "<select " + m + g + ">" + l + "</select>"
        }
    }
    return u
}, _fill_lightbox_select: function (e, t, n, r) {
    if (e[t + r[0]].value = n.getDate(), e[t + r[1]].value = n.getMonth(), e[t + r[2]].value = n.getFullYear(), dhtmlx.defined(r[3])) {
        var i = 60 * n.getHours() + n.getMinutes();
        i = Math.round(i / gantt._get_timepicker_step()) * gantt._get_timepicker_step(), e[t + r[3]].value = i
    }
}, template: {render: function (e) {
    var t = (e.height || "30") + "px";
    return"<div class='dhx_cal_ltext dhx_cal_template' style='height:" + t + ";'></div>"
}, set_value: function (e, t) {
    e.innerHTML = t || ""
}, get_value: function (e) {
    return e.innerHTML || ""
}, focus: function () {
}}, textarea: {render: function (e) {
    var t = (e.height || "130") + "px";
    return"<div class='dhx_cal_ltext' style='height:" + t + ";'><textarea></textarea></div>"
}, set_value: function (e, t) {
    e.firstChild.value = t || ""
}, get_value: function (e) {
    return e.firstChild.value
}, focus: function (e) {
    var t = e.firstChild;
    gantt._focus(t, !0)
}}, select: {render: function (e) {
    for (var t = (e.height || "23") + "px", n = "<div class='dhx_cal_ltext' style='height:" + t + ";'><select style='width:100%;'>", r = 0; r < e.options.length; r++)n += "<option value='" + e.options[r].key + "'>" + e.options[r].label + "</option>";
    return n += "</select></div>"
}, set_value: function (e, t, n, r) {
    var i = e.firstChild;
    !i._dhx_onchange && r.onchange && (i.onchange = r.onchange, i._dhx_onchange = !0), "undefined" == typeof t && (t = (i.options[0] || {}).value), i.value = t || ""
}, get_value: function (e) {
    return e.firstChild.value
}, focus: function (e) {
    var t = e.firstChild;
    gantt._focus(t, !0)
}}, time: {render: function (e) {
    var t = this.form_blocks.getTimePicker.call(this, e), n = ["<div style='height:30px;padding-top:0px;font-size:inherit;text-align:center;' class='dhx_section_time'>"];
    return n.push(t), e.single_date ? (t = this.form_blocks.getTimePicker.call(this, e, !0), n.push("<span></span>")) : n.push("<span style='font-weight:normal; font-size:10pt;'> &nbsp;&ndash;&nbsp; </span>"), n.push(t), n.push("</div>"), n.join("")
}, set_value: function (e, t, n, r) {
    {
        var i = this.config, s = e.getElementsByTagName("select"), o = r._time_format_order;
        r._time_format_size
    }
    if (i.auto_end_date)for (var u = function () {
        var e = new Date(s[o[2]].value, s[o[1]].value, s[o[0]].value, 0, 0), t = gantt.calculateEndDate(e, 1);
        this.form_blocks._fill_lightbox_select(s, o.size, t, o, i)
    }, a = 0; 4 > a; a++)s[a].onchange = u;
    this.form_blocks._fill_lightbox_select(s, 0, n.start_date, o, i), this.form_blocks._fill_lightbox_select(s, o.size, n.end_date, o, i)
}, get_value: function (e, t, n) {
    var r = e.getElementsByTagName("select"), i = n._time_format_order, s = 0, o = 0;
    if (dhtmlx.defined(i[3])) {
        var u = parseInt(r[i[3]].value, 10);
        s = Math.floor(u / 60), o = u % 60
    }
    if (t.start_date = new Date(r[i[2]].value, r[i[1]].value, r[i[0]].value, s, o), s = o = 0, dhtmlx.defined(i[3])) {
        var u = parseInt(r[i.size + i[3]].value, 10);
        s = Math.floor(u / 60), o = u % 60
    }
    return t.end_date = new Date(r[i[2] + i.size].value, r[i[1] + i.size].value, r[i[0] + i.size].value, s, o), t.end_date <= t.start_date && (t.end_date = gantt.date.add(t.start_date, gantt._get_timepicker_step(), "minute")), {start_date: new Date(t.start_date), end_date: new Date(t.end_date)}
}, focus: function (e) {
    gantt._focus(e.getElementsByTagName("select")[0])
}}, duration: {render: function (e) {
    var t = this.form_blocks.getTimePicker.call(this, e);
    t = "<div class='dhx_time_selects'>" + t + "</div>";
    var n = this.locale.labels[this.config.duration_unit + "s"], r = e.single_date ? ' style="display:none"' : "", i = e.readonly ? " disabled='disabled'" : "", s = "<div class='dhx_gantt_duration' " + r + "><input type='button' class='dhx_gantt_duration_dec' value='-'" + i + "><input type='text' value='5' class='dhx_gantt_duration_value'" + i + "><input type='button' class='dhx_gantt_duration_inc' value='+'" + i + "> " + n + " <span></span></div>", o = "<div style='height:30px;padding-top:0px;font-size:inherit;' class='dhx_section_time'>" + t + " " + s + "</div>";
    return o
}, set_value: function (e, t, n, r) {
    function i() {
        var t = gantt.form_blocks.duration._get_start_date.call(gantt, e, r), n = gantt.form_blocks.duration._get_duration.call(gantt, e, r), i = gantt.calculateEndDate(t, n);
        c.innerHTML = gantt.templates.task_date(i)
    }

    function s(e) {
        var t = f.value;
        t = parseInt(t, 10), window.isNaN(t) && (t = 0), t += e, 1 > t && (t = 1), f.value = t, i()
    }

    var o = this.config, u = e.getElementsByTagName("select"), a = e.getElementsByTagName("input"), f = a[1], l = [a[0], a[2]], c = e.getElementsByTagName("span")[0], h = r._time_format_order;
    l[0].onclick = dhtmlx.bind(function () {
        s(-1 * this.config.duration_step)
    }, this), l[1].onclick = dhtmlx.bind(function () {
        s(1 * this.config.duration_step)
    }, this), u[0].onchange = i, u[1].onchange = i, u[2].onchange = i, u[3] && (u[3].onchange = i), f.onkeydown = dhtmlx.bind(function (e) {
        e = e || window.event;
        var t = e.charCode || e.keyCode || e.which;
        return 40 == t ? (s(-1 * this.config.duration_step), !1) : 38 == t ? (s(1 * this.config.duration_step), !1) : void window.setTimeout(function () {
            i()
        }, 1)
    }, this), f.onchange = dhtmlx.bind(function () {
        i()
    }, this), this.form_blocks._fill_lightbox_select(u, 0, n.start_date, h, o);
    var p;
    p = n.end_date ? gantt.calculateDuration(n.start_date, n.end_date) : n.duration, p = Math.round(p), f.value = p, i()
}, _get_start_date: function (e, t) {
    var n = e.getElementsByTagName("select"), r = t._time_format_order, i = 0, s = 0;
    if (dhtmlx.defined(r[3])) {
        var o = parseInt(n[r[3]].value, 10);
        i = Math.floor(o / 60), s = o % 60
    }
    return new Date(n[r[2]].value, n[r[1]].value, n[r[0]].value, i, s)
}, _get_duration: function (e) {
    var t = e.getElementsByTagName("input")[1];
    return t = parseInt(t.value, 10), window.isNaN(t) && (t = 1), 0 > t && (t *= -1), t
}, get_value: function (e, t, n) {
    t.start_date = this.form_blocks.duration._get_start_date(e, n);
    var r = this.form_blocks.duration._get_duration(e, n);
    return t.end_date = this.calculateEndDate(t.start_date, r), t.duration = r, {start_date: new Date(t.start_date), end_date: new Date(t.end_date)}
}, focus: function (e) {
    gantt._focus(e.getElementsByTagName("select")[0])
}}, typeselect: {render: function (e) {
    var t = gantt.config.types, n = gantt.locale.labels, r = [];
    for (var i in t)r.push({key: t[i], label: n["type_" + i]});
    e.options = r;
    var s = e.onchange;
    return e.onchange = function () {
        gantt.getState().lightbox;
        gantt.changeLightboxType(this.value), "function" == typeof s && s.apply(this, arguments)
    }, gantt.form_blocks.select.render.apply(this, arguments)
}, set_value: function () {
    return gantt.form_blocks.select.set_value.apply(this, arguments)
}, get_value: function () {
    return gantt.form_blocks.select.get_value.apply(this, arguments)
}, focus: function () {
    return gantt.form_blocks.select.focus.apply(this, arguments)
}}, parent: {_filter: function (e, t, n) {
    var r = t.filter || function () {
        return!0
    };
    e = e.slice(0);
    for (var i = 0; i < e.length; i++) {
        var s = e[i];
        (s.id == n || gantt.isChildOf(s.id, n) || r(s.id, s) === !1) && (e.splice(i, 1), i--)
    }
    return e
}, _display: function (e, t) {
    var n = [], r = [];
    t && (n = gantt.getTaskByTime(), e.allow_root && n.unshift({id: gantt.config.root_id, text: e.root_label || ""}), n = this._filter(n, e, t), e.sort && n.sort(e.sort));
    for (var i = e.template || gantt.templates.task_text, s = 0; s < n.length; s++) {
        var o = i.apply(gantt, [n[s].start_date, n[s].end_date, n[s]]);
        void 0 === o && (o = ""), r.push({key: n[s].id, label: o})
    }
    return e.options = r, e.map_to = e.map_to || "parent", gantt.form_blocks.select.render.apply(this, arguments)
}, render: function (e) {
    return gantt.form_blocks.parent._display(e, !1)
}, set_value: function (e, t, n, r) {
    var i = document.createElement("div");
    i.innerHTML = gantt.form_blocks.parent._display(r, n.id);
    var s = i.removeChild(i.firstChild);
    return e.onselect = null, e.parentNode.replaceChild(s, e), gantt.form_blocks.select.set_value.apply(this, [s, t, n, r])
}, get_value: function () {
    return gantt.form_blocks.select.get_value.apply(this, arguments)
}, focus: function () {
    return gantt.form_blocks.select.focus.apply(this, arguments)
}}},gantt._is_lightbox_timepicker = function () {
    for (var e = this._get_typed_lightbox_config(), t = 0; t < e.length; t++)if ("time" == e[t].name && "time" == e[t].type)return!0;
    return!1
},gantt._dhtmlx_confirm = function (e, t, n, r) {
    if (!e)return n();
    var i = {text: e};
    t && (i.title = t), r && (i.ok = r), n && (i.callback = function (e) {
        e && n()
    }), dhtmlx.confirm(i)
},gantt._get_typed_lightbox_config = function (e) {
    void 0 === e && (e = this.getLightboxType());
    var t = this._get_type_name(e);
    return gantt.config.lightbox[t + "_sections"] ? gantt.config.lightbox[t + "_sections"] : gantt.config.lightbox.sections
},gantt._silent_redraw_lightbox = function (e) {
    var t = this.getLightboxType();
    if (this.getState().lightbox) {
        var n = this.getState().lightbox, r = this.getLightboxValues(), i = dhtmlx.copy(this.getTask(n));
        this.resetLightbox();
        var s = dhtmlx.mixin(i, r, !0), o = this.getLightbox(e ? e : void 0);
        this._set_lightbox_values(s, o), this._center_lightbox(this.getLightbox()), this.callEvent("onLightboxChange", [t, this.getLightboxType()])
    } else this.resetLightbox(), this.getLightbox(e ? e : void 0);
    this.callEvent("onLightboxChange", [t, this.getLightboxType()])
},dataProcessor.prototype = {setTransactionMode: function (e, t) {
    this._tMode = e, this._tSend = t
}, escape: function (e) {
    return this._utf ? encodeURIComponent(e) : escape(e)
}, enableUTFencoding: function (e) {
    this._utf = convertStringToBoolean(e)
}, setDataColumns: function (e) {
    this._columns = "string" == typeof e ? e.split(",") : e
}, getSyncState: function () {
    return!this.updatedRows.length
}, enableDataNames: function (e) {
    this._endnm = convertStringToBoolean(e)
}, enablePartialDataSend: function (e) {
    this._changed = convertStringToBoolean(e)
}, setUpdateMode: function (e, t) {
    this.autoUpdate = "cell" == e, this.updateMode = e, this.dnd = t
}, ignore: function (e, t) {
    this._silent_mode = !0, e.call(t || window), this._silent_mode = !1
}, setUpdated: function (e, t, n) {
    if (!this._silent_mode) {
        var r = this.findRow(e);
        n = n || "updated";
        var i = this.obj.getUserData(e, this.action_param);
        i && "updated" == n && (n = i), t ? (this.set_invalid(e, !1), this.updatedRows[r] = e, this.obj.setUserData(e, this.action_param, n), this._in_progress[e] && (this._in_progress[e] = "wait")) : this.is_invalid(e) || (this.updatedRows.splice(r, 1), this.obj.setUserData(e, this.action_param, "")), t || this._clearUpdateFlag(e), this.markRow(e, t, n), t && this.autoUpdate && this.sendData(e)
    }
}, _clearUpdateFlag: function () {
}, markRow: function (e, t, n) {
    var r = "", i = this.is_invalid(e);
    if (i && (r = this.styles[i], t = !0), this.callEvent("onRowMark", [e, t, n, i]) && (r = this.styles[t ? n : "clear"] + r, this.obj[this._methods[0]](e, r), i && i.details)) {
        r += this.styles[i + "_cell"];
        for (var s = 0; s < i.details.length; s++)i.details[s] && this.obj[this._methods[1]](e, s, r)
    }
}, getState: function (e) {
    return this.obj.getUserData(e, this.action_param)
}, is_invalid: function (e) {
    return this._invalid[e]
}, set_invalid: function (e, t, n) {
    n && (t = {value: t, details: n, toString: function () {
        return this.value.toString()
    }}), this._invalid[e] = t
}, checkBeforeUpdate: function () {
    return!0
}, sendData: function (e) {
    return!this._waitMode || "tree" != this.obj.mytype && !this.obj._h2 ? (this.obj.editStop && this.obj.editStop(), "undefined" == typeof e || this._tSend ? this.sendAllData() : this._in_progress[e] ? !1 : (this.messages = [], !this.checkBeforeUpdate(e) && this.callEvent("onValidationError", [e, this.messages]) ? !1 : void this._beforeSendData(this._getRowData(e), e))) : void 0
}, _beforeSendData: function (e, t) {
    return this.callEvent("onBeforeUpdate", [t, this.getState(t), e]) ? void this._sendData(e, t) : !1
}, serialize: function (e, t) {
    if ("string" == typeof e)return e;
    if ("undefined" != typeof t)return this.serialize_one(e, "");
    var n = [], r = [];
    for (var i in e)e.hasOwnProperty(i) && (n.push(this.serialize_one(e[i], i + this.post_delim)), r.push(i));
    return n.push("ids=" + this.escape(r.join(","))), dhtmlx.security_key && n.push("dhx_security=" + dhtmlx.security_key), n.join("&")
}, serialize_one: function (e, t) {
    if ("string" == typeof e)return e;
    var n = [];
    for (var r in e)e.hasOwnProperty(r) && n.push(this.escape((t || "") + r) + "=" + this.escape(e[r]));
    return n.join("&")
}, _sendData: function (e, t) {
    if (e) {
        if (!this.callEvent("onBeforeDataSending", t ? [t, this.getState(t), e] : [null, null, e]))return!1;
        t && (this._in_progress[t] = (new Date).valueOf());
        var n = new dtmlXMLLoaderObject(this.afterUpdate, this, !0), r = this.serverProcessor + (this._user ? getUrlSymbol(this.serverProcessor) + ["dhx_user=" + this._user, "dhx_version=" + this.obj.getUserData(0, "version")].join("&") : "");
        "POST" != this._tMode ? n.loadXML(r + (-1 != r.indexOf("?") ? "&" : "?") + this.serialize(e, t)) : n.loadXML(r, !0, this.serialize(e, t)), this._waitMode++
    }
}, sendAllData: function () {
    if (this.updatedRows.length) {
        this.messages = [];
        for (var e = !0, t = 0; t < this.updatedRows.length; t++)e &= this.checkBeforeUpdate(this.updatedRows[t]);
        if (!e && !this.callEvent("onValidationError", ["", this.messages]))return!1;
        if (this._tSend)this._sendData(this._getAllData()); else for (var t = 0; t < this.updatedRows.length; t++)if (!this._in_progress[this.updatedRows[t]]) {
            if (this.is_invalid(this.updatedRows[t]))continue;
            if (this._beforeSendData(this._getRowData(this.updatedRows[t]), this.updatedRows[t]), this._waitMode && ("tree" == this.obj.mytype || this.obj._h2))return
        }
    }
}, _getAllData: function () {
    for (var e = {}, t = !1, n = 0; n < this.updatedRows.length; n++) {
        var r = this.updatedRows[n];
        this._in_progress[r] || this.is_invalid(r) || this.callEvent("onBeforeUpdate", [r, this.getState(r)]) && (e[r] = this._getRowData(r, r + this.post_delim), t = !0, this._in_progress[r] = (new Date).valueOf())
    }
    return t ? e : null
}, setVerificator: function (e, t) {
    this.mandatoryFields[e] = t || function (e) {
        return"" !== e
    }
}, clearVerificator: function (e) {
    this.mandatoryFields[e] = !1
}, findRow: function (e) {
    var t = 0;
    for (t = 0; t < this.updatedRows.length && e != this.updatedRows[t]; t++);
    return t
}, defineAction: function (e, t) {
    this._uActions || (this._uActions = []), this._uActions[e] = t
}, afterUpdateCallback: function (e, t, n, r) {
    var i = e, s = "error" != n && "invalid" != n;
    if (s || this.set_invalid(e, n), this._uActions && this._uActions[n] && !this._uActions[n](r))return delete this._in_progress[i];
    "wait" != this._in_progress[i] && this.setUpdated(e, !1);
    var o = e;
    switch (n) {
        case"inserted":
        case"insert":
            t != e && (this.obj[this._methods[2]](e, t), e = t);
            break;
        case"delete":
        case"deleted":
            return this.obj.setUserData(e, this.action_param, "true_deleted"), this.obj[this._methods[3]](e), delete this._in_progress[i], this.callEvent("onAfterUpdate", [e, n, t, r])
    }
    "wait" != this._in_progress[i] ? (s && this.obj.setUserData(e, this.action_param, ""), delete this._in_progress[i]) : (delete this._in_progress[i], this.setUpdated(t, !0, this.obj.getUserData(e, this.action_param))), this.callEvent("onAfterUpdate", [o, n, t, r])
}, afterUpdate: function (e, t, n, r, i) {
    if (i.getXMLTopNode("data"), i.xmlDoc.responseXML) {
        for (var s = i.doXPath("//data/action"), o = 0; o < s.length; o++) {
            var u = s[o], a = u.getAttribute("type"), f = u.getAttribute("sid"), l = u.getAttribute("tid");
            e.afterUpdateCallback(f, l, a, u)
        }
        e.finalizeUpdate()
    }
}, finalizeUpdate: function () {
    this._waitMode && this._waitMode--, ("tree" == this.obj.mytype || this.obj._h2) && this.updatedRows.length && this.sendData(), this.callEvent("onAfterUpdateFinish", []), this.updatedRows.length || this.callEvent("onFullSync", [])
}, init: function (e) {
    this.obj = e, this.obj._dp_init && this.obj._dp_init(this)
}, setOnAfterUpdate: function (e) {
    this.attachEvent("onAfterUpdate", e)
}, enableDebug: function () {
}, setOnBeforeUpdateHandler: function (e) {
    this.attachEvent("onBeforeDataSending", e)
}, setAutoUpdate: function (e, t) {
    e = e || 2e3, this._user = t || (new Date).valueOf(), this._need_update = !1, this._loader = null, this._update_busy = !1, this.attachEvent("onAfterUpdate", function (e, t, n, r) {
        this.afterAutoUpdate(e, t, n, r)
    }), this.attachEvent("onFullSync", function () {
        this.fullSync()
    });
    var n = this;
    window.setInterval(function () {
        n.loadUpdate()
    }, e)
}, afterAutoUpdate: function (e, t) {
    return"collision" == t ? (this._need_update = !0, !1) : !0
}, fullSync: function () {
    return this._need_update === !0 && (this._need_update = !1, this.loadUpdate()), !0
}, getUpdates: function (e, t) {
    return this._update_busy ? !1 : (this._update_busy = !0, this._loader = this._loader || new dtmlXMLLoaderObject(!0), this._loader.async = !0, this._loader.waitCall = t, void this._loader.loadXML(e))
}, _v: function (e) {
    return e.firstChild ? e.firstChild.nodeValue : ""
}, _a: function (e) {
    for (var t = [], n = 0; n < e.length; n++)t[n] = this._v(e[n]);
    return t
}, loadUpdate: function () {
    var e = this, t = this.obj.getUserData(0, "version"), n = this.serverProcessor + getUrlSymbol(this.serverProcessor) + ["dhx_user=" + this._user, "dhx_version=" + t].join("&");
    n = n.replace("editing=true&", ""), this.getUpdates(n, function () {
        var t = e._loader.doXPath("//userdata");
        e.obj.setUserData(0, "version", e._v(t[0]));
        var n = e._loader.doXPath("//update");
        if (n.length) {
            e._silent_mode = !0;
            for (var r = 0; r < n.length; r++) {
                var i = n[r].getAttribute("status"), s = n[r].getAttribute("id"), o = n[r].getAttribute("parent");
                switch (i) {
                    case"inserted":
                        e.callEvent("insertCallback", [n[r], s, o]);
                        break;
                    case"updated":
                        e.callEvent("updateCallback", [n[r], s, o]);
                        break;
                    case"deleted":
                        e.callEvent("deleteCallback", [n[r], s, o])
                }
            }
            e._silent_mode = !1
        }
        e._update_busy = !1, e = null
    })
}},dhtmlx.assert = function (e, t) {
    e || dhtmlx.message({type: "error", text: t, expire: -1})
},gantt.init = function (e, t, n) {
    t && n && (this.config.start_date = this._min_date = new Date(t), this.config.end_date = this._max_date = new Date(n)), this._init_skin(), this.config.scroll_size || (this.config.scroll_size = this._detectScrollSize()), this._reinit(e), this.attachEvent("onLoadEnd", this.render), dhtmlxEvent(window, "resize", this._on_resize), this.init = function (e) {
        this.$container && (this.$container.innerHTML = ""), this._reinit(e)
    }, this.callEvent("onGanttReady", [])
},gantt._reinit = function (e) {
    this._init_html_area(e), this._set_sizes(), this._task_area_pulls = {}, this._task_area_renderers = {}, this._init_touch_events(), this._init_templates(), this._init_grid(), this._init_tasks(), this.render(), this._set_scroll_events(), dhtmlxEvent(this.$container, "click", this._on_click), dhtmlxEvent(this.$container, "dblclick", this._on_dblclick), dhtmlxEvent(this.$container, "mousemove", this._on_mousemove), dhtmlxEvent(this.$container, "contextmenu", this._on_contextmenu)
},gantt._init_html_area = function (e) {
    this._obj = "string" == typeof e ? document.getElementById(e) : e, dhtmlx.assert(this._obj, "Invalid html container: " + e);
    var t = "<div class='gantt_container'><div class='gantt_grid'></div><div class='gantt_task'></div>";
    t += "<div class='gantt_ver_scroll'><div></div></div><div class='gantt_hor_scroll'><div></div></div></div>", this._obj.innerHTML = t, this.$container = this._obj.firstChild;
    var n = this.$container.childNodes;
    this.$grid = n[0], this.$task = n[1], this.$scroll_ver = n[2], this.$scroll_hor = n[3], this.$grid.innerHTML = "<div class='gantt_grid_scale'></div><div class='gantt_grid_data'></div>", this.$grid_scale = this.$grid.childNodes[0], this.$grid_data = this.$grid.childNodes[1], this.$task.innerHTML = "<div class='gantt_task_scale'></div><div class='gantt_data_area'><div class='gantt_task_bg'></div><div class='gantt_links_area'></div><div class='gantt_bars_area'></div></div>", this.$task_scale = this.$task.childNodes[0], this.$task_data = this.$task.childNodes[1], this.$task_bg = this.$task_data.childNodes[0], this.$task_links = this.$task_data.childNodes[1], this.$task_bars = this.$task_data.childNodes[2]
},gantt.$click = {buttons: {edit: function (e) {
    gantt.showLightbox(e)
}, "delete": function (e) {
    var t = gantt.locale.labels.confirm_deleting, n = gantt.locale.labels.confirm_deleting_title;
    gantt._dhtmlx_confirm(t, n, function () {
        var t = gantt.getTask(e);
        t.$new ? (gantt._deleteTask(e, !0), gantt.refreshData()) : gantt.deleteTask(e), gantt.hideLightbox()
    })
}}},gantt._calculate_content_height = function () {
    var e = this.config.scale_height, t = this._order.length * this.config.row_height, n = this._scroll_hor ? this.config.scroll_size + 1 : 0;
    return this._is_grid_visible() || this._is_chart_visible() ? e + t + 2 + n : 0
},gantt._calculate_content_width = function () {
    {
        var e = this._get_grid_width(), t = this._tasks ? this._tasks.full_width : 0;
        this._scroll_ver ? this.config.scroll_size + 1 : 0
    }
    return this._is_chart_visible() || (t = 0), this._is_grid_visible() || (e = 0), e + t + 1
},gantt._get_resize_options = function () {
    var e = {x: !1, y: !1};
    return"xy" == this.config.autosize ? e.x = e.y = !0 : "y" == this.config.autosize || this.config.autosize === !0 ? e.y = !0 : "x" == this.config.autosize && (e.x = !0), e
},gantt._set_sizes = function () {
    var e = this._get_resize_options();
    if (e.y && (this._obj.style.height = this._calculate_content_height() + "px"), e.x && (this._obj.style.width = this._calculate_content_width() + "px"), this._y = this._obj.clientHeight, !(this._y < 20)) {
        this.$grid.style.height = this.$task.style.height = Math.max(this._y - this.$scroll_hor.offsetHeight - 2, 0) + "px";
        var t = Math.max(this._y - (this.config.scale_height || 0) - this.$scroll_hor.offsetHeight - 2, 0);
        this.$grid_data.style.height = this.$task_data.style.height = t + "px";
        var n = Math.max(this._get_grid_width() - 1, 0);
        this.$grid.style.width = n + "px", this.$grid.style.display = 0 === n ? "none" : "", this._x = this._obj.clientWidth, this._x < 20 || (this.$grid_data.style.width = Math.max(this._get_grid_width() - 1, 0) + "px", this.$task.style.width = Math.max(this._x - this._get_grid_width() - 2, 0) + "px")
    }
},gantt.getScrollState = function () {
    return{x: this.$task.scrollLeft, y: this.$task_data.scrollTop}
},gantt.scrollTo = function (e, t) {
    1 * e == e && (this.$task.scrollLeft = e), 1 * t == t && (this.$task_data.scrollTop = t, this.$grid_data.scrollTop = t)
},gantt.showDate = function (e) {
    var t = this.posFromDate(e), n = Math.max(t - this.config.task_scroll_offset, 0);
    this.scrollTo(n)
},gantt.showTask = function (e) {
    var t = this.getTaskNode(e);
    if (t) {
        var n = Math.max(t.offsetLeft - this.config.task_scroll_offset, 0), r = t.offsetTop - (this.$task_data.offsetHeight - this.config.row_height) / 2;
        this.scrollTo(n, r)
    }
},gantt._on_resize = gantt.setSizes = function () {
    gantt._set_sizes(), gantt._scroll_resize()
},gantt.render = function () {
    if (this._render_grid(), this._render_tasks_scales(), this._scroll_resize(), this._on_resize(), this._render_data(), this.config.initial_scroll) {
        var e = this._order[0] || this.config.root_id;
        e && this.showTask(e)
    }
    this.callEvent("onGanttRender", [])
},gantt._set_scroll_events = function () {
    dhtmlxEvent(this.$scroll_hor, "scroll", function () {
        if (!gantt._touch_scroll_active) {
            var e = gantt.$scroll_hor.scrollLeft;
            gantt.scrollTo(e)
        }
    }), dhtmlxEvent(this.$scroll_ver, "scroll", function () {
        if (!gantt._touch_scroll_active) {
            var e = gantt.$scroll_ver.scrollTop;
            gantt.$grid_data.scrollTop = e, gantt.scrollTo(null, e)
        }
    }), dhtmlxEvent(this.$task, "scroll", function () {
        var e = gantt.$task.scrollLeft, t = gantt.$scroll_hor.scrollLeft;
        t != e && (gantt.$scroll_hor.scrollLeft = e)
    }), dhtmlxEvent(this.$task_data, "scroll", function () {
        var e = gantt.$task_data.scrollTop, t = gantt.$scroll_ver.scrollTop;
        t != e && (gantt.$scroll_ver.scrollTop = e)
    }), dhtmlxEvent(gantt.$container, "mousewheel", function (e) {
        var t = gantt._get_resize_options();
        if (e.wheelDeltaX) {
            if (t.x)return!0;
            var n = e.wheelDeltaX / -40, r = gantt.$task.scrollLeft + 30 * n;
            gantt.scrollTo(r, null), gantt.$scroll_hor.scrollTop = i
        } else {
            if (t.y)return!0;
            var n = e.wheelDelta / -40;
            "undefined" == typeof e.wheelDelta && (n = e.detail);
            var i = gantt.$grid_data.scrollTop + 30 * n;
            gantt.scrollTo(null, i), gantt.$scroll_ver.scrollTop = i
        }
        return e.preventDefault && e.preventDefault(), e.cancelBubble = !0, !1
    })
},gantt._scroll_resize = function () {
    if (!(this._x < 20 || this._y < 20)) {
        var e = this._get_grid_width(), t = this._x - e, n = this._y - this.config.scale_height, r = this.config.scroll_size + 1, i = this.$task_data.offsetWidth - r, s = this.config.row_height * this._order.length, o = this._get_resize_options(), u = this._scroll_hor = o.x ? !1 : i > t, a = this._scroll_ver = o.y ? !1 : s > n;
        this.$scroll_hor.style.display = u ? "block" : "none", this.$scroll_hor.style.height = (u ? r : 0) + "px", this.$scroll_hor.style.width = this._x - (a ? r : 2) + "px", this.$scroll_hor.firstChild.style.width = i + e + r + 2 + "px", this.$scroll_ver.style.display = a ? "block" : "none", this.$scroll_ver.style.width = (a ? r : 0) + "px", this.$scroll_ver.style.height = this._y - (u ? r : 0) - this.config.scale_height + "px", this.$scroll_ver.style.top = this.config.scale_height + "px", this.$scroll_ver.firstChild.style.height = this.config.scale_height + s + "px"
    }
},gantt.locate = function (e) {
    var t = gantt._get_target_node(e);
    if ("gantt_task_cell" == t.className)return null;
    for (var n = arguments[1] || this.config.task_attribute; t;) {
        if (t.getAttribute) {
            var r = t.getAttribute(n);
            if (r)return r
        }
        t = t.parentNode
    }
    return null
},gantt._get_target_node = function (e) {
    var t;
    return e.tagName ? t = e : (e = e || window.event, t = e.target || e.srcElement), t
},gantt._trim = function (e) {
    var t = String.prototype.trim || function () {
        return this.replace(/^\s+|\s+$/g, "")
    };
    return t.apply(e)
},gantt._locate_css = function (e, t, n) {
    void 0 === n && (n = !0);
    for (var r = gantt._get_target_node(e), i = ""; r;) {
        if (i = r.className) {
            var s = i.indexOf(t);
            if (s >= 0) {
                if (!n)return r;
                var o = 0 === s || !gantt._trim(i.charAt(s - 1)), u = s + t.length >= i.length || !gantt._trim(i.charAt(s + t.length));
                if (o && u)return r
            }
        }
        r = r.parentNode
    }
    return null
},gantt._locateHTML = function (e, t) {
    var n = gantt._get_target_node(e);
    for (t = t || this.config.task_attribute; n;) {
        if (n.getAttribute) {
            var r = n.getAttribute(t);
            if (r)return n
        }
        n = n.parentNode
    }
    return null
},gantt.getTaskRowNode = function (e) {
    for (var t = this.$grid_data.childNodes, n = this.config.task_attribute, r = 0; r < t.length; r++)if (t[r].getAttribute) {
        var i = t[r].getAttribute(n);
        if (i == e)return t[r]
    }
    return null
},gantt.getState = function () {
    return{drag_id: this._tasks_dnd.drag.id, drag_mode: this._tasks_dnd.drag.mode, drag_from_start: this._tasks_dnd.drag.left, selected_task: this._selected_task, min_date: new Date(this._min_date), max_date: new Date(this._max_date), lightbox: this._lightbox_id}
},gantt._checkTimeout = function (e, t) {
    if (!t)return!0;
    var n = 1e3 / t;
    return 1 > n ? !0 : e._on_timeout ? !1 : (setTimeout(function () {
        delete e._on_timeout
    }, n), e._on_timeout = !0, !0)
},gantt.selectTask = function (e) {
    if (!this.config.select_task)return!1;
    if (e) {
        if (this._selected_task == e)return this._selected_task;
        if (!this.callEvent("onBeforeTaskSelected", [e]))return!1;
        this.unselectTask(), this._selected_task = e, this.refreshTask(e), this.callEvent("onTaskSelected", [e])
    }
    return this._selected_task
},gantt.unselectTask = function () {
    var e = this._selected_task;
    e && (this._selected_task = null, this.refreshTask(e), this.callEvent("onTaskUnselected", [e]))
},gantt.getSelectedId = function () {
    return dhtmlx.defined(this._selected_task) ? this._selected_task : null
},gantt.changeLightboxType = function (e) {
    return this.getLightboxType() == e ? !0 : void gantt._silent_redraw_lightbox(e)
},gantt.date = {init: function () {
    for (var e = gantt.locale.date.month_short, t = gantt.locale.date.month_short_hash = {}, n = 0; n < e.length; n++)t[e[n]] = n;
    for (var e = gantt.locale.date.month_full, t = gantt.locale.date.month_full_hash = {}, n = 0; n < e.length; n++)t[e[n]] = n
}, date_part: function (e) {
    return e.setHours(0), e.setMinutes(0), e.setSeconds(0), e.setMilliseconds(0), e.getHours() && e.setTime(e.getTime() + 36e5 * (24 - e.getHours())), e
}, time_part: function (e) {
    return(e.valueOf() / 1e3 - 60 * e.getTimezoneOffset()) % 86400
}, week_start: function (e) {
    var t = e.getDay();
    return gantt.config.start_on_monday && (0 === t ? t = 6 : t--), this.date_part(this.add(e, -1 * t, "day"))
}, month_start: function (e) {
    return e.setDate(1), this.date_part(e)
}, year_start: function (e) {
    return e.setMonth(0), this.month_start(e)
}, day_start: function (e) {
    return this.date_part(e)
}, hour_start: function (e) {
    var t = e.getHours();
    return this.day_start(e), e.setHours(t), e
}, minute_start: function (e) {
    var t = e.getMinutes();
    return this.hour_start(e), e.setMinutes(t), e
}, _add_days: function (e, t) {
    var n = new Date(e.valueOf());
    return n.setDate(n.getDate() + t), !e.getHours() && n.getHours() && n.setTime(n.getTime() + 36e5 * (24 - n.getHours())), n
}, add: function (e, t, n) {
    var r = new Date(e.valueOf());
    switch (n) {
        case"day":
            r = gantt.date._add_days(r, t);
            break;
        case"week":
            r = gantt.date._add_days(r, 7 * t);
            break;
        case"month":
            r.setMonth(r.getMonth() + t);
            break;
        case"year":
            r.setYear(r.getFullYear() + t);
            break;
        case"hour":
            r.setTime(r.getTime() + 60 * t * 60 * 1e3);
            break;
        case"minute":
            r.setTime(r.getTime() + 60 * t * 1e3);
            break;
        default:
            return gantt.date["add_" + n](e, t, n)
    }
    return r
}, to_fixed: function (e) {
    return 10 > e ? "0" + e : e
}, copy: function (e) {
    return new Date(e.valueOf())
}, date_to_str: function (e, t) {
    return e = e.replace(/%[a-zA-Z]/g, function (e) {
        switch (e) {
            case"%d":
                return'"+gantt.date.to_fixed(date.getDate())+"';
            case"%m":
                return'"+gantt.date.to_fixed((date.getMonth()+1))+"';
            case"%j":
                return'"+date.getDate()+"';
            case"%n":
                return'"+(date.getMonth()+1)+"';
            case"%y":
                return'"+gantt.date.to_fixed(date.getFullYear()%100)+"';
            case"%Y":
                return'"+date.getFullYear()+"';
            case"%D":
                return'"+gantt.locale.date.day_short[date.getDay()]+"';
            case"%l":
                return'"+gantt.locale.date.day_full[date.getDay()]+"';
            case"%M":
                return'"+gantt.locale.date.month_short[date.getMonth()]+"';
            case"%F":
                return'"+gantt.locale.date.month_full[date.getMonth()]+"';
            case"%h":
                return'"+gantt.date.to_fixed((date.getHours()+11)%12+1)+"';
            case"%g":
                return'"+((date.getHours()+11)%12+1)+"';
            case"%G":
                return'"+date.getHours()+"';
            case"%H":
                return'"+gantt.date.to_fixed(date.getHours())+"';
            case"%i":
                return'"+gantt.date.to_fixed(date.getMinutes())+"';
            case"%a":
                return'"+(date.getHours()>11?"pm":"am")+"';
            case"%A":
                return'"+(date.getHours()>11?"PM":"AM")+"';
            case"%s":
                return'"+gantt.date.to_fixed(date.getSeconds())+"';
            case"%W":
                return'"+gantt.date.to_fixed(gantt.date.getISOWeek(date))+"';
            default:
                return e
        }
    }), t && (e = e.replace(/date\.get/g, "date.getUTC")), new Function("date", 'return "' + e + '";')
}, str_to_date: function (e, t) {
    for (var n = "var temp=date.match(/[a-zA-Z]+|[0-9]+/g);", r = e.match(/%[a-zA-Z]/g), i = 0; i < r.length; i++)switch (r[i]) {
        case"%j":
        case"%d":
            n += "set[2]=temp[" + i + "]||1;";
            break;
        case"%n":
        case"%m":
            n += "set[1]=(temp[" + i + "]||1)-1;";
            break;
        case"%y":
            n += "set[0]=temp[" + i + "]*1+(temp[" + i + "]>50?1900:2000);";
            break;
        case"%g":
        case"%G":
        case"%h":
        case"%H":
            n += "set[3]=temp[" + i + "]||0;";
            break;
        case"%i":
            n += "set[4]=temp[" + i + "]||0;";
            break;
        case"%Y":
            n += "set[0]=temp[" + i + "]||0;";
            break;
        case"%a":
        case"%A":
            n += "set[3]=set[3]%12+((temp[" + i + "]||'').toLowerCase()=='am'?0:12);";
            break;
        case"%s":
            n += "set[5]=temp[" + i + "]||0;";
            break;
        case"%M":
            n += "set[1]=gantt.locale.date.month_short_hash[temp[" + i + "]]||0;";
            break;
        case"%F":
            n += "set[1]=gantt.locale.date.month_full_hash[temp[" + i + "]]||0;"
    }
    var s = "set[0],set[1],set[2],set[3],set[4],set[5]";
    return t && (s = " Date.UTC(" + s + ")"), new Function("date", "var set=[0,0,1,0,0,0]; " + n + " return new Date(" + s + ");")
}, getISOWeek: function (e) {
    if (!e)return!1;
    var t = e.getDay();
    0 === t && (t = 7);
    var n = new Date(e.valueOf());
    n.setDate(e.getDate() + (4 - t));
    var r = n.getFullYear(), i = Math.round((n.getTime() - (new Date(r, 0, 1)).getTime()) / 864e5), s = 1 + Math.floor(i / 7);
    return s
}, getUTCISOWeek: function (e) {
    return this.getISOWeek(e)
}, convert_to_utc: function (e) {
    return new Date(e.getUTCFullYear(), e.getUTCMonth(), e.getUTCDate(), e.getUTCHours(), e.getUTCMinutes(), e.getUTCSeconds())
}, parseDate: function (e, t) {
    return"string" == typeof e && (dhtmlx.defined(t) && (t = "string" == typeof t ? dhtmlx.defined(gantt.templates[t]) ? gantt.templates[t] : gantt.date.str_to_date(t) : gantt.templates.xml_date), e = t(e)), e
}},gantt.config || (gantt.config = {}),gantt.config || (gantt.config = {}),gantt.templates || (gantt.templates = {}),function () {
    dhtmlx.mixin(gantt.config, {links: {finish_to_start: "0", start_to_start: "1", finish_to_finish: "2", start_to_finish: "3"}, types: {task: "task", project: "project", milestone: "milestone"}, duration_unit: "day", work_time: !1, correct_work_time: !1, skip_off_time: !1, autosize: !1, show_links: !0, show_task_cells: !0, show_chart: !0, show_grid: !0, min_duration: 36e5, xml_date: "%d-%m-%Y %H:%i", api_date: "%d-%m-%Y %H:%i", start_on_monday: !0, server_utc: !1, show_progress: !0, fit_tasks: !1, select_task: !0, readonly: !1, date_grid: "%Y-%m-%d", drag_links: !0, drag_progress: !0, drag_resize: !0, drag_move: !0, drag_mode: {resize: "resize", progress: "progress", move: "move", ignore: "ignore"}, round_dnd_dates: !0, link_wrapper_width: 20, root_id: 0, autofit: !0, columns: [
        {name: "text", tree: !0, width: "*"},
        {name: "start_date", align: "center"},
        {name: "duration", align: "center"},
        {name: "add", width: "44"}
    ], step: 1, scale_unit: "day", subscales: [], time_step: 60, duration_step: 1, date_scale: "%d %M", task_date: "%d %F %Y", time_picker: "%H:%i", task_attribute: "task_id", link_attribute: "link_id", buttons_left: ["dhx_save_btn", "dhx_cancel_btn"], buttons_right: ["dhx_delete_btn"], lightbox: {sections: [
        {name: "description", height: 70, map_to: "text", type: "textarea", focus: !0},
        {name: "time", height: 72, type: "duration", map_to: "auto"}
    ], project_sections: [
        {name: "description", height: 70, map_to: "text", type: "textarea", focus: !0},
        {name: "type", type: "typeselect", map_to: "type"},
        {name: "time", height: 72, type: "duration", readonly: !0, map_to: "auto"}
    ], milestone_sections: [
        {name: "description", height: 70, map_to: "text", type: "textarea", focus: !0},
        {name: "type", type: "typeselect", map_to: "type"},
        {name: "time", height: 72, type: "duration", single_date: !0, map_to: "auto"}
    ]}, drag_lightbox: !0, sort: !1, details_on_create: !0, details_on_dblclick: !0, initial_scroll: !0, task_scroll_offset: 100, task_height: "full", min_column_width: 50}), gantt.keys = {edit_save: 13, edit_cancel: 27}, gantt._init_template = function (e, t) {
        var n = this._reg_templates || {};
        this.config[e] && n[e] != this.config[e] && (t && this.templates[e] || (this.templates[e] = this.date.date_to_str(this.config[e]), n[e] = this.config[e])), this._reg_templates = n
    }, gantt._init_templates = function () {
        var e = gantt.locale.labels;
        e.dhx_save_btn = e.icon_save, e.dhx_cancel_btn = e.icon_cancel, e.dhx_delete_btn = e.icon_delete;
        var t = this.date.date_to_str, n = this.config;
        gantt._init_template("date_scale", !0), gantt._init_template("date_grid", !0), gantt._init_template("task_date", !0), dhtmlx.mixin(this.templates, {xml_date: this.date.str_to_date(n.xml_date, n.server_utc), xml_format: t(n.xml_date, n.server_utc), api_date: this.date.str_to_date(n.api_date), progress_text: function () {
            return""
        }, grid_header_class: function () {
            return""
        }, task_text: function (e, t, n) {
            return n.text
        }, task_class: function () {
            return""
        }, grid_row_class: function () {
            return""
        }, task_row_class: function () {
            return""
        }, task_cell_class: function () {
            return""
        }, scale_cell_class: function () {
            return""
        }, scale_row_class: function () {
            return""
        }, grid_indent: function () {
            return"<div class='gantt_tree_indent'></div>"
        }, grid_folder: function (e) {
            return"<div class='gantt_tree_icon gantt_folder_" + (e.$open ? "open" : "closed") + "'></div>"
        }, grid_file: function () {
            return"<div class='gantt_tree_icon gantt_file'></div>"
        }, grid_open: function (e) {
            return"<div class='gantt_tree_icon gantt_" + (e.$open ? "close" : "open") + "'></div>"
        }, grid_blank: function () {
            return"<div class='gantt_tree_icon gantt_blank'></div>"
        }, task_time: function (e, t) {
            return gantt.templates.task_date(e) + " - " + gantt.templates.task_date(t)
        }, time_picker: t(n.time_picker), link_class: function () {
            return""
        }, link_description: function (e) {
            var t = gantt.getTask(e.source), n = gantt.getTask(e.target);
            return"<b>" + t.text + "</b> &ndash;  <b>" + n.text + "</b>"
        }, drag_link: function (e, t, n, r) {
            e = gantt.getTask(e);
            var i = gantt.locale.labels, s = "<b>" + e.text + "</b> " + (t ? i.link_start : i.link_end) + "<br/>";
            return n && (n = gantt.getTask(n), s += "<b> " + n.text + "</b> " + (r ? i.link_start : i.link_end) + "<br/>"), s
        }, drag_link_class: function (e, t, n, r) {
            var i = "";
            if (e && n) {
                var s = gantt.isLinkAllowed(e, n, t, r);
                i = " " + (s ? "gantt_link_allow" : "gantt_link_deny")
            }
            return"gantt_link_tooltip" + i
        }}), this.callEvent("onTemplatesReady", [])
    }
}(),window.jQuery && !function (e) {
    var t = [];
    e.fn.dhx_gantt = function (n) {
        if (n = n || {}, "string" != typeof n) {
            var r = [];
            return this.each(function () {
                if (this && this.getAttribute && !this.getAttribute("dhxgantt")) {
                    for (var e in n)"data" != e && (gantt.config[e] = n[e]);
                    gantt.init(this), n.data && gantt.parse(n.data), r.push(gantt)
                }
            }), 1 === r.length ? r[0] : r
        }
        return t[n] ? t[n].apply(this, []) : void e.error("Method " + n + " does not exist on jQuery.dhx_gantt")
    }
}(jQuery),window.dhtmlx && (dhtmlx.attaches || (dhtmlx.attaches = {}), dhtmlx.attaches.attachGantt = function (e, t) {
    var n = document.createElement("DIV");
    n.id = "gantt_" + dhtmlx.uid(), n.style.width = "100%", n.style.height = "100%", n.cmp = "grid", document.body.appendChild(n), this.attachObject(n.id);
    var r = this.vs[this.av];
    r.grid = gantt, gantt.init(n.id, e, t), n.firstChild.style.border = "none", r.gridId = n.id, r.gridObj = n;
    var i = "_viewRestore";
    return this.vs[this[i]()].grid
}),gantt.locale = {date: {month_full: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], month_short: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], day_full: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], day_short: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]}, labels: {new_task: "New task", icon_save: "Save", icon_cancel: "Cancel", icon_details: "Details", icon_edit: "Edit", icon_delete: "Delete", confirm_closing: "", confirm_deleting: "Task will be deleted permanently, are you sure?", section_description: "Description", section_time: "Time period", section_type: "Type", column_text: "Task name", column_start_date: "Start time", column_duration: "Duration", column_add: "", link: "Link", confirm_link_deleting: "will be deleted", link_start: " (start)", link_end: " (end)", type_task: "Task", type_project: "Project", type_milestone: "Milestone", minutes: "Minutes", hours: "Hours", days: "Days", weeks: "Week", months: "Months", years: "Years"}},gantt.skins.skyblue = {config: {grid_width: 350, row_height: 27, scale_height: 27, task_height: 24, link_line_width: 1, link_arrow_size: 8, lightbox_additional_height: 75}, _second_column_width: 95, _third_column_width: 80},gantt.skins.meadow = {config: {grid_width: 350, row_height: 27, scale_height: 30, task_height: 24, link_line_width: 2, link_arrow_size: 6, lightbox_additional_height: 72}, _second_column_width: 95, _third_column_width: 80},gantt.skins.terrace = {config: {grid_width: 360, row_height: 35, scale_height: 35, task_height: 24, link_line_width: 2, link_arrow_size: 6, lightbox_additional_height: 75}, _second_column_width: 90, _third_column_width: 70},gantt.skins.broadway = {config: {grid_width: 360, row_height: 35, scale_height: 35, task_height: 24, link_line_width: 1, link_arrow_size: 7, lightbox_additional_height: 86}, _second_column_width: 90, _third_column_width: 80, _lightbox_template: "<div class='dhx_cal_ltitle'><span class='dhx_mark'>&nbsp;</span><span class='dhx_time'></span><span class='dhx_title'></span><div class='dhx_cancel_btn'></div></div><div class='dhx_cal_larea'></div>", _config_buttons_left: {}, _config_buttons_right: {dhx_delete_btn: "icon_delete", dhx_save_btn: "icon_save"}},gantt.config.touch_drag = 50,gantt.config.touch = !0,gantt._init_touch_events = function () {
    "force" != this.config.touch && (this.config.touch = this.config.touch && (-1 != navigator.userAgent.indexOf("Mobile") || -1 != navigator.userAgent.indexOf("iPad") || -1 != navigator.userAgent.indexOf("Android") || -1 != navigator.userAgent.indexOf("Touch"))), this.config.touch && (window.navigator.msPointerEnabled ? this._touch_events(["MSPointerMove", "MSPointerDown", "MSPointerUp"], function (e) {
        return e.pointerType == e.MSPOINTER_TYPE_MOUSE ? null : e
    }, function (e) {
        return!e || e.pointerType == e.MSPOINTER_TYPE_MOUSE
    }) : this._touch_events(["touchmove", "touchstart", "touchend"], function (e) {
        return e.touches && e.touches.length > 1 ? null : e.touches[0] ? {target: e.target, pageX: e.touches[0].pageX, pageY: e.touches[0].pageY} : e
    }, function () {
        return!1
    }))
},gantt._touch_events = function (e, t, n) {
    function r(e) {
        return e && e.preventDefault && e.preventDefault(), (e || event).cancelBubble = !0, !1
    }

    var i, s = 0, o = !1, u = !1, a = null;
    this._gantt_touch_event_ready || (this._gantt_touch_event_ready = 1, dhtmlxEvent(document.body, e[0], function (e) {
        if (!n(e) && o) {
            var f = t(e);
            if (f && a) {
                var l = a.pageX - f.pageX, c = a.pageY - f.pageY;
                !u && (Math.abs(l) > 5 || Math.abs(c) > 5) && (gantt._touch_scroll_active = u = !0, s = 0, i = gantt.getScrollState()), u && gantt.scrollTo(i.x + l, i.y + c)
            }
            return r(e)
        }
    })), dhtmlxEvent(this.$container, "contextmenu", function (e) {
        return o ? r(e) : void 0
    }), dhtmlxEvent(this.$container, e[1], function (e) {
        if (!n(e)) {
            if (e.touches && e.touches.length > 1)return void (o = !1);
            if (o = !0, a = t(e), a && s) {
                var i = new Date;
                500 > i - s ? (gantt._on_dblclick(a), r(e)) : s = i
            } else s = new Date
        }
    }), dhtmlxEvent(this.$container, e[2], function (e) {
        n(e) || (gantt._touch_scroll_active = o = u = !1)
    })
}