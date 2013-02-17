(function(e){"use strict";var t,n,r;if(typeof window==="undefined"){t=require("underscore");n=require("backbone");r=module.exports=n}else{t=window._;n=window.Backbone;r=window}n.Relational={showWarnings:true};n.Semaphore={_permitsAvailable:null,_permitsUsed:0,acquire:function(){if(this._permitsAvailable&&this._permitsUsed>=this._permitsAvailable){throw new Error("Max permits acquired")}else{this._permitsUsed++}},release:function(){if(this._permitsUsed===0){throw new Error("All permits released")}else{this._permitsUsed--}},isLocked:function(){return this._permitsUsed>0},setAvailablePermits:function(e){if(this._permitsUsed>e){throw new Error("Available permits cannot be less than used permits")}this._permitsAvailable=e}};n.BlockingQueue=function(){this._queue=[]};t.extend(n.BlockingQueue.prototype,n.Semaphore,{_queue:null,add:function(e){if(this.isBlocked()){this._queue.push(e)}else{e()}},process:function(){while(this._queue&&this._queue.length){this._queue.shift()()}},block:function(){this.acquire()},unblock:function(){this.release();if(!this.isBlocked()){this.process()}},isBlocked:function(){return this.isLocked()}});n.Relational.eventQueue=new n.BlockingQueue;n.Store=function(){this._collections=[];this._reverseRelations=[];this._subModels=[];this._modelScopes=[r]};t.extend(n.Store.prototype,n.Events,{addModelScope:function(e){this._modelScopes.push(e)},addSubModels:function(e,t){this._subModels.push({superModelType:t,subModels:e})},setupSuperModel:function(e){t.find(this._subModels||[],function(n){return t.find(n.subModels||[],function(t,r){var i=this.getObjectByName(t);if(e===i){n.superModelType._subModels[r]=e;e._superModel=n.superModelType;e._subModelTypeValue=r;e._subModelTypeAttribute=n.superModelType.prototype.subModelTypeAttribute;return true}},this)},this)},addReverseRelation:function(e){var n=t.any(this._reverseRelations||[],function(n){return t.all(e||[],function(e,t){return e===n[t]})});if(!n&&e.model&&e.type){this._reverseRelations.push(e);var r=function(e,n){if(!e.prototype.relations){e.prototype.relations=[]}e.prototype.relations.push(n);t.each(e._subModels||[],function(e){r(e,n)},this)};r(e.model,e);this.retroFitRelation(e)}},retroFitRelation:function(e){var t=this.getCollection(e.model);t.each(function(t){if(!(t instanceof e.model)){return}new e.type(t,e)},this)},getCollection:function(e){if(e instanceof n.RelationalModel){e=e.constructor}var r=e;while(r._superModel){r=r._superModel}var i=t.detect(this._collections,function(e){return e.model===r});if(!i){i=this._createCollection(r)}return i},getObjectByName:function(n){var r=n.split("."),i=null;t.find(this._modelScopes||[],function(n){i=t.reduce(r||[],function(t,n){return t?t[n]:e},n);if(i&&i!==n){return true}},this);return i},_createCollection:function(e){var t;if(e instanceof n.RelationalModel){e=e.constructor}if(e.prototype instanceof n.RelationalModel){t=new n.Collection;t.model=e;this._collections.push(t)}return t},resolveIdForItem:function(e,r){var i=t.isString(r)||t.isNumber(r)?r:null;if(i===null){if(r instanceof n.RelationalModel){i=r.id}else if(t.isObject(r)){i=r[e.prototype.idAttribute]}}if(!i&&i!==0){i=null}return i},find:function(e,t){var n=this.resolveIdForItem(e,t);var r=this.getCollection(e);if(r){var i=r.get(n);if(i instanceof e){return i}}return null},register:function(e){var t=this.getCollection(e);if(t){if(t.get(e)){throw new Error("Cannot instantiate more than one Backbone.RelationalModel with the same id per type!")}var n=e.collection;t.add(e);e.bind("destroy",this.unregister,this);e.collection=n}},update:function(e){var t=this.getCollection(e);t._onModelEvent("change:"+e.idAttribute,e,t)},unregister:function(e){e.unbind("destroy",this.unregister);var t=this.getCollection(e);t&&t.remove(e)}});n.Relational.store=new n.Store;n.Relation=function(e,r){this.instance=e;r=t.isObject(r)?r:{};this.reverseRelation=t.defaults(r.reverseRelation||{},this.options.reverseRelation);this.reverseRelation.type=!t.isString(this.reverseRelation.type)?this.reverseRelation.type:n[this.reverseRelation.type]||n.Relational.store.getObjectByName(this.reverseRelation.type);this.model=r.model||this.instance.constructor;this.options=t.defaults(r,this.options,n.Relation.prototype.options);this.key=this.options.key;this.keySource=this.options.keySource||this.key;this.keyDestination=this.options.keyDestination||this.keySource||this.key;this.relatedModel=this.options.relatedModel;if(t.isString(this.relatedModel)){this.relatedModel=n.Relational.store.getObjectByName(this.relatedModel)}if(!this.checkPreconditions()){return}if(e){var i=this.keySource;if(i!==this.key&&typeof this.instance.get(this.key)==="object"){i=this.key}this.keyContents=this.instance.get(i);if(this.keySource!==this.key){this.instance.unset(this.keySource,{silent:true})}this.instance._relations.push(this)}if(!this.options.isAutoRelation&&this.reverseRelation.type&&this.reverseRelation.key){n.Relational.store.addReverseRelation(t.defaults({isAutoRelation:true,model:this.relatedModel,relatedModel:this.model,reverseRelation:this.options},this.reverseRelation))}t.bindAll(this,"_modelRemovedFromCollection","_relatedModelAdded","_relatedModelRemoved");if(e){this.initialize();if(r.autoFetch){this.instance.fetchRelated(r.key,t.isObject(r.autoFetch)?r.autoFetch:{})}n.Relational.store.getCollection(this.instance).bind("relational:remove",this._modelRemovedFromCollection);n.Relational.store.getCollection(this.relatedModel).bind("relational:add",this._relatedModelAdded).bind("relational:remove",this._relatedModelRemoved)}};n.Relation.extend=n.Model.extend;t.extend(n.Relation.prototype,n.Events,n.Semaphore,{options:{createModels:true,includeInJSON:true,isAutoRelation:false,autoFetch:false},instance:null,key:null,keyContents:null,relatedModel:null,reverseRelation:null,related:null,_relatedModelAdded:function(e,t,n){var r=this;e.queue(function(){r.tryAddRelated(e,n)})},_relatedModelRemoved:function(e,t,n){this.removeRelated(e,n)},_modelRemovedFromCollection:function(e){if(e===this.instance){this.destroy()}},checkPreconditions:function(){var e=this.instance,r=this.key,i=this.model,s=this.relatedModel,o=n.Relational.showWarnings&&typeof console!=="undefined";if(!i||!r||!s){o&&console.warn("Relation=%o; no model, key or relatedModel (%o, %o, %o)",this,i,r,s);return false}if(!(i.prototype instanceof n.RelationalModel)){o&&console.warn("Relation=%o; model does not inherit from Backbone.RelationalModel (%o)",this,e);return false}if(!(s.prototype instanceof n.RelationalModel)){o&&console.warn("Relation=%o; relatedModel does not inherit from Backbone.RelationalModel (%o)",this,s);return false}if(this instanceof n.HasMany&&this.reverseRelation.type===n.HasMany){o&&console.warn("Relation=%o; relation is a HasMany, and the reverseRelation is HasMany as well.",this);return false}if(e&&e._relations.length){var u=t.any(e._relations||[],function(e){var t=this.reverseRelation.key&&e.reverseRelation.key;return e.relatedModel===s&&e.key===r&&(!t||this.reverseRelation.key===e.reverseRelation.key)},this);if(u){o&&console.warn("Relation=%o between instance=%o.%s and relatedModel=%o.%s already exists",this,e,r,s,this.reverseRelation.key);return false}}return true},setRelated:function(e,n){this.related=e;this.instance.acquire();this.instance.set(this.key,e,t.defaults(n||{},{silent:true}));this.instance.release()},_isReverseRelation:function(e){if(e.instance instanceof this.relatedModel&&this.reverseRelation.key===e.key&&this.key===e.reverseRelation.key){return true}return false},getReverseRelations:function(e){var n=[];var r=!t.isUndefined(e)?[e]:this.related&&(this.related.models||[this.related]);t.each(r||[],function(e){t.each(e.getRelations()||[],function(e){if(this._isReverseRelation(e)){n.push(e)}},this)},this);return n},sanitizeOptions:function(e){e=e?t.clone(e):{};if(e.silent){e.silentChange=true;delete e.silent}return e},unsanitizeOptions:function(e){e=e?t.clone(e):{};if(e.silentChange){e.silent=true;delete e.silentChange}return e},destroy:function(){n.Relational.store.getCollection(this.instance).unbind("relational:remove",this._modelRemovedFromCollection);n.Relational.store.getCollection(this.relatedModel).unbind("relational:add",this._relatedModelAdded).unbind("relational:remove",this._relatedModelRemoved);t.each(this.getReverseRelations()||[],function(e){e.removeRelated(this.instance)},this)}});n.HasOne=n.Relation.extend({options:{reverseRelation:{type:"HasMany"}},initialize:function(){t.bindAll(this,"onChange");this.instance.bind("relational:change:"+this.key,this.onChange);var e=this.findRelated({silent:true});this.setRelated(e);t.each(this.getReverseRelations()||[],function(e){e.addRelated(this.instance)},this)},findRelated:function(e){var t=this.keyContents;var n=null;if(t instanceof this.relatedModel){n=t}else if(t||t===0){n=this.relatedModel.findOrCreate(t,{create:this.options.createModels})}return n},onChange:function(e,r,i){if(this.isLocked()){return}this.acquire();i=this.sanitizeOptions(i);var s=t.isUndefined(i._related);var o=s?this.related:i._related;if(s){this.keyContents=r;if(r instanceof this.relatedModel){this.related=r}else if(r){var u=this.findRelated(i);this.setRelated(u)}else{this.setRelated(null)}}if(o&&this.related!==o){t.each(this.getReverseRelations(o)||[],function(e){e.removeRelated(this.instance,i)},this)}t.each(this.getReverseRelations()||[],function(e){e.addRelated(this.instance,i)},this);if(!i.silentChange&&this.related!==o){var a=this;n.Relational.eventQueue.add(function(){a.instance.trigger("update:"+a.key,a.instance,a.related,i)})}this.release()},tryAddRelated:function(e,r){if(this.related){return}r=this.sanitizeOptions(r);var i=this.keyContents;if(i||i===0){var s=n.Relational.store.resolveIdForItem(this.relatedModel,i);if(!t.isNull(s)&&e.id===s){this.addRelated(e,r)}}},addRelated:function(e,t){if(e!==this.related){var n=this.related||null;this.setRelated(e);this.onChange(this.instance,e,{_related:n})}},removeRelated:function(e,t){if(!this.related){return}if(e===this.related){var n=this.related||null;this.setRelated(null);this.onChange(this.instance,e,{_related:n})}}});n.HasMany=n.Relation.extend({collectionType:null,options:{reverseRelation:{type:"HasOne"},collectionType:n.Collection,collectionKey:true,collectionOptions:{}},initialize:function(){t.bindAll(this,"onChange","handleAddition","handleRemoval","handleReset");this.instance.bind("relational:change:"+this.key,this.onChange);this.collectionType=this.options.collectionType;if(t.isString(this.collectionType)){this.collectionType=n.Relational.store.getObjectByName(this.collectionType)}if(!this.collectionType.prototype instanceof n.Collection){throw new Error("collectionType must inherit from Backbone.Collection")}if(this.keyContents instanceof n.Collection){this.setRelated(this._prepareCollection(this.keyContents))}else{this.setRelated(this._prepareCollection())}this.findRelated({silent:true})},_getCollectionOptions:function(){return t.isFunction(this.options.collectionOptions)?this.options.collectionOptions(this.instance):this.options.collectionOptions},_prepareCollection:function(e){if(this.related){this.related.unbind("relational:add",this.handleAddition).unbind("relational:remove",this.handleRemoval).unbind("relational:reset",this.handleReset)}if(!e||!(e instanceof n.Collection)){e=new this.collectionType([],this._getCollectionOptions())}e.model=this.relatedModel;if(this.options.collectionKey){var t=this.options.collectionKey===true?this.options.reverseRelation.key:this.options.collectionKey;if(e[t]&&e[t]!==this.instance){if(n.Relational.showWarnings&&typeof console!=="undefined"){console.warn("Relation=%o; collectionKey=%s already exists on collection=%o",this,t,this.options.collectionKey)}}else if(t){e[t]=this.instance}}e.bind("relational:add",this.handleAddition).bind("relational:remove",this.handleRemoval).bind("relational:reset",this.handleReset);return e},findRelated:function(e){if(this.keyContents){var r=[];if(this.keyContents instanceof n.Collection){r=this.keyContents.models}else{this.keyContents=t.isArray(this.keyContents)?this.keyContents:[this.keyContents];t.each(this.keyContents||[],function(e){var t=null;if(e instanceof this.relatedModel){t=e}else if(e||e===0){t=this.relatedModel.findOrCreate(e,{create:this.options.createModels})}if(t&&!this.related.get(t)){r.push(t)}},this)}if(r.length){e=this.unsanitizeOptions(e);this.related.add(r,e)}}},onChange:function(r,i,s){s=this.sanitizeOptions(s);this.keyContents=i;if(i instanceof n.Collection){this._prepareCollection(i);this.related=i}else{var o={},u={};if(!t.isArray(i)&&i!==e){i=[i]}t.each(i,function(e){u[e.id]=true});var a=this.related;if(a instanceof n.Collection){t.each(a.models.slice(0),function(e){if(!s.keepNewModels||!e.isNew()){o[e.id]=true;a.remove(e,{silent:e.id in u})}})}else{a=this._prepareCollection()}t.each(i,function(e){var t=this.relatedModel.findOrCreate(e,{create:this.options.createModels});if(t){a.add(t,{silent:e.id in o})}},this);this.setRelated(a)}var f=this;n.Relational.eventQueue.add(function(){!s.silentChange&&f.instance.trigger("update:"+f.key,f.instance,f.related,s)})},tryAddRelated:function(e,r){r=this.sanitizeOptions(r);if(!this.related.get(e)){var i=t.any(this.keyContents||[],function(r){var i=n.Relational.store.resolveIdForItem(this.relatedModel,r);return!t.isNull(i)&&i===e.id},this);if(i){this.related.add(e,r)}}},handleAddition:function(e,r,i){if(!(e instanceof n.Model)){return}i=this.sanitizeOptions(i);t.each(this.getReverseRelations(e)||[],function(e){e.addRelated(this.instance,i)},this);var s=this;n.Relational.eventQueue.add(function(){!i.silentChange&&s.instance.trigger("add:"+s.key,e,s.related,i)})},handleRemoval:function(e,r,i){if(!(e instanceof n.Model)){return}i=this.sanitizeOptions(i);t.each(this.getReverseRelations(e)||[],function(e){e.removeRelated(this.instance,i)},this);var s=this;n.Relational.eventQueue.add(function(){!i.silentChange&&s.instance.trigger("remove:"+s.key,e,s.related,i)})},handleReset:function(e,t){t=this.sanitizeOptions(t);var r=this;n.Relational.eventQueue.add(function(){!t.silentChange&&r.instance.trigger("reset:"+r.key,r.related,t)})},addRelated:function(e,t){var n=this;t=this.unsanitizeOptions(t);e.queue(function(){if(n.related&&!n.related.get(e)){n.related.add(e,t)}})},removeRelated:function(e,t){t=this.unsanitizeOptions(t);if(this.related.get(e)){this.related.remove(e,t)}}});n.RelationalModel=n.Model.extend({relations:null,_relations:null,_isInitialized:false,_deferProcessing:false,_queue:null,subModelTypeAttribute:"type",subModelTypes:null,constructor:function(e,r){var i=this;if(r&&r.collection){this._deferProcessing=true;var s=function(e){if(e===i){i._deferProcessing=false;i.processQueue();r.collection.unbind("relational:add",s)}};r.collection.bind("relational:add",s);t.defer(function(){s(i)})}this._queue=new n.BlockingQueue;this._queue.block();n.Relational.eventQueue.block();n.Model.apply(this,arguments);n.Relational.eventQueue.unblock()},trigger:function(e){if(e.length>5&&"change"===e.substr(0,6)){var t=this,r=arguments;n.Relational.eventQueue.add(function(){n.Model.prototype.trigger.apply(t,r)})}else{n.Model.prototype.trigger.apply(this,arguments)}return this},initializeRelations:function(){this.acquire();this._relations=[];t.each(this.relations||[],function(e){var r=!t.isString(e.type)?e.type:n[e.type]||n.Relational.store.getObjectByName(e.type);if(r&&r.prototype instanceof n.Relation){new r(this,e)}else{n.Relational.showWarnings&&typeof console!=="undefined"&&console.warn("Relation=%o; missing or invalid type!",e)}},this);this._isInitialized=true;this.release();this.processQueue()},updateRelations:function(e){if(this._isInitialized&&!this.isLocked()){t.each(this._relations||[],function(t){var n=this.attributes[t.keySource]||this.attributes[t.key];if(t.related!==n){this.trigger("relational:change:"+t.key,this,n,e||{})}},this)}},queue:function(e){this._queue.add(e)},processQueue:function(){if(this._isInitialized&&!this._deferProcessing&&this._queue.isBlocked()){this._queue.unblock()}},getRelation:function(e){return t.detect(this._relations,function(t){if(t.key===e){return true}},this)},getRelations:function(){return this._relations},fetchRelated:function(e,r,i){r||(r={});var s,o=[],u=this.getRelation(e),a=u&&u.keyContents,f=a&&t.select(t.isArray(a)?a:[a],function(e){var r=n.Relational.store.resolveIdForItem(u.relatedModel,e);return!t.isNull(r)&&(i||!n.Relational.store.find(u.relatedModel,r))},this);if(f&&f.length){var l=t.map(f,function(e){var n;if(t.isObject(e)){n=u.relatedModel.findOrCreate(e)}else{var r={};r[u.relatedModel.prototype.idAttribute]=e;n=u.relatedModel.findOrCreate(r)}return n},this);if(u.related instanceof n.Collection&&t.isFunction(u.related.url)){s=u.related.url(l)}if(s&&s!==u.related.url()){var c=t.defaults({error:function(){var e=arguments;t.each(l||[],function(t){t.trigger("destroy",t,t.collection,r);r.error&&r.error.apply(t,e)})},url:s},r,{add:true});o=[u.related.fetch(c)]}else{o=t.map(l||[],function(e){var n=t.defaults({error:function(){e.trigger("destroy",e,e.collection,r);r.error&&r.error.apply(e,arguments)}},r);return e.fetch(n)},this)}}return o},set:function(e,r,i){n.Relational.eventQueue.block();var s;if(t.isObject(e)||e==null){s=e;i=r}else{s={};s[e]=r}var o=n.Model.prototype.set.apply(this,arguments);if(!this._isInitialized&&!this.isLocked()){this.constructor.initializeModelHierarchy();n.Relational.store.register(this);this.initializeRelations()}else if(s&&this.idAttribute in s){n.Relational.store.update(this)}if(s){this.updateRelations(i)}n.Relational.eventQueue.unblock();return o},unset:function(e,t){n.Relational.eventQueue.block();var r=n.Model.prototype.unset.apply(this,arguments);this.updateRelations(t);n.Relational.eventQueue.unblock();return r},clear:function(e){n.Relational.eventQueue.block();var t=n.Model.prototype.clear.apply(this,arguments);this.updateRelations(e);n.Relational.eventQueue.unblock();return t},change:function(e){var t=this,r=arguments;n.Relational.eventQueue.add(function(){n.Model.prototype.change.apply(t,r)})},clone:function(){var e=t.clone(this.attributes);if(!t.isUndefined(e[this.idAttribute])){e[this.idAttribute]=null}t.each(this.getRelations()||[],function(t){delete e[t.key]});return new this.constructor(e)},toJSON:function(e){if(this.isLocked()){return this.id}this.acquire();var r=n.Model.prototype.toJSON.call(this,e);if(this.constructor._superModel&&!(this.constructor._subModelTypeAttribute in r)){r[this.constructor._subModelTypeAttribute]=this.constructor._subModelTypeValue}t.each(this._relations||[],function(i){var s=r[i.key];if(i.options.includeInJSON===true){if(s&&t.isFunction(s.toJSON)){r[i.keyDestination]=s.toJSON(e)}else{r[i.keyDestination]=null}}else if(t.isString(i.options.includeInJSON)){if(s instanceof n.Collection){r[i.keyDestination]=s.pluck(i.options.includeInJSON)}else if(s instanceof n.Model){r[i.keyDestination]=s.get(i.options.includeInJSON)}else{r[i.keyDestination]=null}}else if(t.isArray(i.options.includeInJSON)){if(s instanceof n.Collection){var o=[];s.each(function(e){var n={};t.each(i.options.includeInJSON,function(t){n[t]=e.get(t)});o.push(n)});r[i.keyDestination]=o}else if(s instanceof n.Model){var o={};t.each(i.options.includeInJSON,function(e){o[e]=s.get(e)});r[i.keyDestination]=o}else{r[i.keyDestination]=null}}else{delete r[i.key]}if(i.keyDestination!==i.key){delete r[i.key]}});this.release();return r}},{setup:function(e){this.prototype.relations=(this.prototype.relations||[]).slice(0);this._subModels={};this._superModel=null;if(this.prototype.hasOwnProperty("subModelTypes")){n.Relational.store.addSubModels(this.prototype.subModelTypes,this)}else{this.prototype.subModelTypes=null}t.each(this.prototype.relations||[],function(e){if(!e.model){e.model=this}if(e.reverseRelation&&e.model===this){var r=true;if(t.isString(e.relatedModel)){var i=n.Relational.store.getObjectByName(e.relatedModel);r=i&&i.prototype instanceof n.RelationalModel}var s=!t.isString(e.type)?e.type:n[e.type]||n.Relational.store.getObjectByName(e.type);if(r&&s&&s.prototype instanceof n.Relation){new s(null,e)}}},this);return this},build:function(e,t){var n=this;this.initializeModelHierarchy();if(this._subModels&&this.prototype.subModelTypeAttribute in e){var r=e[this.prototype.subModelTypeAttribute];var i=this._subModels[r];if(i){n=i}}return new n(e,t)},initializeModelHierarchy:function(){if(t.isUndefined(this._superModel)||t.isNull(this._superModel)){n.Relational.store.setupSuperModel(this);if(this._superModel){if(this._superModel.prototype.relations){var e=t.any(this.prototype.relations||[],function(e){return e.model&&e.model!==this},this);if(!e){this.prototype.relations=this._superModel.prototype.relations.concat(this.prototype.relations)}}}else{this._superModel=false}}if(this.prototype.subModelTypes&&t.keys(this.prototype.subModelTypes).length!==t.keys(this._subModels).length){t.each(this.prototype.subModelTypes||[],function(e){var t=n.Relational.store.getObjectByName(e);t&&t.initializeModelHierarchy()})}},findOrCreate:function(e,r){var i=t.isObject(e)&&this.prototype.parse?this.prototype.parse(e):e;var s=n.Relational.store.find(this,i);if(t.isObject(e)){if(s){s.set(i,r)}else if(!r||r&&r.create!==false){s=this.build(e,r)}}return s}});t.extend(n.RelationalModel.prototype,n.Semaphore);n.Collection.prototype.__prepareModel=n.Collection.prototype._prepareModel;n.Collection.prototype._prepareModel=function(e,t){var r;if(e instanceof n.Model){if(!e.collection){e.collection=this}r=e}else{t||(t={});t.collection=this;if(typeof this.model.findOrCreate!=="undefined"){r=this.model.findOrCreate(e,t)}else{r=new this.model(e,t)}if(!r._validate(e,t)){r=false}}return r};var i=n.Collection.prototype.__add=n.Collection.prototype.add;n.Collection.prototype.add=function(e,r){r||(r={});if(!t.isArray(e)){e=[e]}var s=[];t.each(e||[],function(e){if(!(e instanceof n.Model)){e=n.Collection.prototype._prepareModel.call(this,e,r)}if(e instanceof n.Model&&!this.get(e)){s.push(e)}},this);if(s.length){i.call(this,s,r);t.each(s||[],function(e){this.trigger("relational:add",e,this,r)},this)}return this};var s=n.Collection.prototype.__remove=n.Collection.prototype.remove;n.Collection.prototype.remove=function(e,r){r||(r={});if(!t.isArray(e)){e=[e]}else{e=e.slice(0)}t.each(e||[],function(e){e=this.get(e);if(e instanceof n.Model){s.call(this,e,r);this.trigger("relational:remove",e,this,r)}},this);return this};var o=n.Collection.prototype.__reset=n.Collection.prototype.reset;n.Collection.prototype.reset=function(e,t){o.call(this,e,t);this.trigger("relational:reset",this,t);return this};var u=n.Collection.prototype.__sort=n.Collection.prototype.sort;n.Collection.prototype.sort=function(e){u.call(this,e);this.trigger("relational:reset",this,e);return this};var a=n.Collection.prototype.__trigger=n.Collection.prototype.trigger;n.Collection.prototype.trigger=function(e){if(e==="add"||e==="remove"||e==="reset"){var r=this,i=arguments;if(e==="add"){i=t.toArray(i);if(t.isObject(i[3])){i[3]=t.clone(i[3])}}n.Relational.eventQueue.add(function(){a.apply(r,i)})}else{a.apply(this,arguments)}return this};n.RelationalModel.extend=function(e,t){var r=n.Model.extend.apply(this,arguments);r.setup(this);return r}})()