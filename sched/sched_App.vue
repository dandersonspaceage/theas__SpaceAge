<template>
  <div :style="{ cursor: curCursor}">

    <b-container id="NewPage1_Appvue">

      <b-row no-gutters fluid>

        <b-col>     

            <b-row>
              <b-col cols="4">
                <b-form-group label="Press"
                              :label-for="'ListName'">
                  <b-form-select :id="'listName'"
                                v-model="curWOList" :options="woListNames" @change="switchWOList()"
                                size="sm"></b-form-select>
                </b-form-group>
              </b-col>

              <b-col cols="4">
                <b-form-group label="Search"
                              :label-for="'search'">
                  <b-input :id="'search'"
                                v-model="searchTarget" @keyup="onSearchKeyUp" debounce="100" placeholder="search..."
                                size="sm"></b-input>
                </b-form-group>                
              </b-col>         

              <b-col cols="4" v-if="false">
                <b-textarea id="soSeqText" debounce="300"
                      v-model="soSeqText" rows="5" max-rows="5">
                </b-textarea>
                <b-button @click="applySOSeq">Apply Seq.</b-button>
              </b-col>  
            </b-row>

            <h6>[[ curWOList ]] (<span v-if="isBusy()">Loading</span><span v-if="!isBusy()">[[ visibleWOs.length ]]</span><span>orders</span>)</h6>
              <div class="fastscroll" style="height:75vh;">

                <draggable v-model="visibleWOs" group="wo" handle=".dragHandle" :disabled="disableDraggable" @start="drag=true" @end="drag=false" @change="onDropWO">

                  <b-card v-for="wo in visibleWOs" :key="wo.qguid" :class="{ lastToMove: wo.LastToMove }">
                    <b-row>
                      <b-col>

                        <b-row>

                          <b-col>
                            <b-row>
                              <b-col>                                
                                <h1 cols="1" class="dragHandle" ><span class="badge badge-secondary">[[ wo.Seq ]]</span></h1>                                
                              </b-col>

                              <b-col cols="6">
                                <h5><span class="badge badge-secondary" v-if="!wo.LastToMove" @click="doRepeatMove(wo.qguid, $event)">Repeat Move</span></h5>
                                <h5><span class="badge badge-secondary" @click="doMoveFirst(wo.qguid, $event)">Move First</span></h5>
                              </b-col>
                            </b-row>

                          
                          </b-col>          

                          <b-col>
                            <h6>WO: [[ wo.WONumber ]]</h6>

                             <b-form-group label="Release to Press" :label-for="'releasePress' + wo.qguid" label-size="sm" label-cols="6" :label-align="'left'" class="m-0 p-0" label-class="m-0 p-0">
                              <b-checkbox :id="'releasePress' + wo.qguid" v-model="wo.ReleasedToPress" @change="onReleaseClick(wo.qguid, $event)" class="m-0 p-0"></b-checkbox>  
                             </b-form-group>

                             <b-button size="sm" variant="outline-primary" @click="onCompleteClick(wo.qguid, $event)" class="m-0 p-0">Press Complete</b-button>
                          </b-col>
                          <b-col>
                            <h6>SO: [[ wo.LinkedSONumber ]]</h6>
                          </b-col>
                        
                        </b-row>

                        <b-row>
                          <b-col>
                            <h6>[[ wo.CustomerName ]]</h6>
                          </b-col>
                        </b-row>

                        <b-row>
                          <b-col>
                            <h6>Item: [[ wo.ItemNumber ]]</h6>
                          </b-col>
                          <b-col>
                            <h6>Foam: [[ wo.FoamSystem ]] </h6>
                          </b-col>
                          <b-col>
                          </b-col>
                        </b-row>

                        <b-row>
                          <b-col>
                            <h6>Qty: [[ wo.Quantity ]]<span class='bg-warning' v-if="wo.CurrentShotCount">Qty Remaining:
                              [[ wo.QtyRemaining ]]</span></h6>
                          </b-col>

                          <b-col>
                            <h6>Boards in front: [[ wo.BoardsInFront ]]</h6>
                          </b-col>

                          <b-col>
                            <h6>Press Hours in front: [[ wo.PressHoursInFrontStr ]]</h6>
                          </b-col>                      

                        </b-row>


                        <b-row>
                          <b-col>
                            <b-btn v-b-toggle="'collapse' + wo.qguid" @click="toggleWODetail(wo.qguid, $event)">
                              <span class="when-opened">
                                <i class="fa fa-chevron-down" aria-hidden="true"></i>
                              </span>
                              <span class="when-closed">       
                                <i class="fa fa-chevron-up" aria-hidden="true"></i>
                                  [[ formatDate(wo.RequestDate, 'ddd MM/DD') ]]   
                                </span>
                            </b-btn>
                          </b-col>

                          <b-col>
                            <span class='bg-warning' v-if="!wo.EstShipDate">No Commit Date</span>
                          </b-col>

                          <b-col>

                            <b-btn variant="info" size="sm" v-b-toggle="'collapseSplit' + wo.qguid">Split WO

                              <span class="when-opened">
                                <i class="fa fa-chevron-down" aria-hidden="true"></i>
                              </span>
                              <span class="when-closed">       
                                <i class="fa fa-chevron-up" aria-hidden="true"></i>
                              </span>

                            </b-btn>
                          </b-col>
                        </b-row>
                    
                        <b-collapse :id="'collapseSplit' + wo.qguid">
                          <b-row>
                            <b-col offset-md="6">

                              
                              <b-form-group v-for="n in 6" :label="'Qty Batch ' + n" :label-for="'SplitNoWOs' + n" :key="wo.qguid + '.' + n">
                                <b-form-input :id="'SplitNoWOs' + n" size="sm" v-model="splitNoWOs[n]"></b-form-input>
                              </b-form-group>                     

                            </b-col>
                          </b-row>
                        </b-collapse>

                
                        <b-collapse :id="'collapse' + wo.qguid">
                          <b-row>
                            <b-col>
                              <p>[[ wo.ItemDescription ]]</p>
                            </b-col>
                          </b-row>

                          <b-row>
                            <b-col>
                              Sugg. Press: <b>[[ wo.SuggestedPress ]]</b>
                            </b-col>
                            <b-col>
                              <b-form-group label="Planned Press"
                                            :label-for="'planpress' + [[ wo.qguid ]]">
                                <b-form-select :id="'planpress' + [[ wo.qguid ]]"
                                              v-model="wo.PlannedPress" :options="pressCodes" @change="setDirty(wo.qguid, 0, true)"
                                              size="sm"></b-form-select>
                              </b-form-group>
                            </b-col>
                          </b-row>

                          <b-row>
                            <b-col>
                              <b-table-simple class="table-borderless table-sm">
                                <b-tbody>


                                  <b-tr>
                                    <b-td>
                                      Commit Date
                                    </b-td>
                                    <b-td>

                                      <b-form-datepicker :id="'dp' + [[ wo.qguid ]]"
                                                        :date-format-options="{year:undefined, month: '2-digit', day: '2-digit', weekday: 'short' }"
                                                        v-model="wo.EstShipDate"
                                                        :min="today" @input="setDirty(wo.qguid, 0)"
                                                        size="sm" :dark="true" locale="en">
                                      </b-form-datepicker>

                                    </b-td>
                                  </b-tr>

                                  <b-tr>
                                    <b-td>
                                      Calc. Press ETA Date
                                    </b-td>
                                    <b-td>
                                      [[ formatDate(wo.CalcPressETA, 'ddd MM/DD') ]]
                                    </b-td>
                                  </b-tr>


                                  <b-tr>
                                    <b-td>
                                      Request Date
                                    </b-td>
                                    <b-td>
                                      [[ formatDate(wo.RequestDate, 'ddd MM/DD') ]]
                                    </b-td>
                                  </b-tr>

                                </b-tbody>
                              </b-table-simple>
                            </b-col>
                          </b-row>

                          <b-row>
                            <b-col>
                              <b-form-group label="Notes" :label-for="'notes' + [[wo.qguid]]">
                                <b-form-textarea :id="'notes' + [[wo.qguid]]" debounce="300"
                                                @keyup="setDirty(wo.qguid, 3000, false, $event)"
                                                v-model="wo.Notes" rows="3" max-rows="3">
                                </b-form-textarea>
                              </b-form-group>
                            </b-col>
                          </b-row>

                        </b-collapse>
                        
                      </b-col>

                      <b-col cols="1">

                        <div @click="clickBookmark(wo.qguid, $event)" @mousedown="mousedownBookmark" @mouseup.stop.prevent="mouseupBookmark" class="bookmark" :class="{ bookmark1: ('1'==wo.BookmarkCode), bookmark2: ('2'==wo.BookmarkCode), bookmark3: ('3'==wo.BookmarkCode) }"></div>                                                                                   

                      </b-col>
                    </b-row>
                  </b-card>

                </draggable>                   

              </div>

        </b-col>

      </b-row>

    </b-container>

    <b-modal id="thModal" ref="thModal" @hide="onthModalHide($event)" hide-footer>
      <template #modal-title>
        [[ theasLastError.msgTitle ]]
      </template>
      <div class="d-block text-center">
        <h3>[[ theasLastError.msgFriendly ]]</h3>
        <h5>[[ theasLastError.msgTech ]]</h5>        
      </div>
    </b-modal>

  </div>

</template>

<script>
  //import TestBSVTable from  "{{ '/saltd/TestBSVTable.vue'|theasResource }}";
  //import { NavbarPlugin } from 'bootstrap-vue'
  //Vue.use(NavbarPlugin)
  //import draggable from "@/vuedraggable";

  export default {
    delimiters: ["[[", "]]"],

    data() {
      return {
        theasParams: {},
        theasLastError: {},
                
        dataRefreshInterval: 15,
        enableFetching: true,
        today: moment().toDate(),
        busyCount: 1,
        curCursor: 'progress',
        dirtyQGUIDs: [], // list of qguids that need to be saved
        dirtyTimers: [], // timers for pending saves of qugids

        overlayVisible: false,
        searchTarget: '',

        drag: null,
        disableDraggable: false,
        ignoreMouseup: false,

        // Dynamic data will be fetched asynchronously
        data_WOs: [],
        visibleWOs: [],

        soSeqText: '',

        lastFetch_WOs: null,

        asyncResource_WOs: 'sched/sched_App.vue',
        asyncCmd_WOs: 'fetchWOs',

        pressCodes: ['N', 'NE', 'NW', 'S', 'W'],

        woListNames: ['Unscheduled', 'N', 'NE', 'NW', 'S', 'W'],
        curWOList: 'Unscheduled',

        data_ThisWO: {},

        thisWO_EstShipDate: null, // object for datepicker

        splitNoWOs: []

      };
    },

    /*
    computed: {
      filteredWOs : function () {
        if (this.searchTarget) {
          return this.data_WOs.filter(wo => (
              (wo.WONumber && wo.WONumber.indexOf(this.searchTarget) >= 0) || 
              (wo.LinkedSONumber && wo.LinkedSONumber.indexOf(this.searchTarget) >= 0) ||
              (wo.ItemNumber && wo.ItemNumber.indexOf(this.searchTarget) >= 0)
          ));              
        }
        else {
          return this.data_WOs;
        }
      }
    },
    */

    // method executed when the Vue object is created
    created: function () {
      let thatVue = this;

 
      //$th is created automatically (by recipe in sched.js / xxxxx.js) however, it is NOT reactive.
      //For example, $th.theasParams[someParam] is not reactive.
      //So we declared data.theasParams and initialized to an empty object above, and here
      //we update the reference to point data.theasParams to thatVue.th.theasParams
      //thereby making theasParams reactive.

      //Note however that properties that are added to these objects after these references
      //are set will NOT be reactive unless you set them using vm.$set() or Vue.set(),
      //or (possibly) via Object.assign().

      //In the future it would be nice if $th took care of making sure that new theasParams
      //were reactive.
      thatVue.theasParams = thatVue.$th.theasParams;
      thatVue.theasLastError = thatVue.$th.lastError;

      /* placeholder / example of how you can ovrride $th.thModal with any object
      that exposes a showMessage() method.

      $th.thModal is used to display error messages.
      
      The default is that $th.thModal will use a BootstrapVue modal message box. 
      If you choose not to use BootstrapVue the default will fall back to an alert.
      But you are free to define as you see fit.

      thatVue.$th.thModal = {
        showMessage: function(msg) {
          alert(msg);
        }
      }
      */

      // perform the initial fetch of data
      this.fetchData(true);
    },

    // method executed when the Vue object is mounted / done rendering
    mounted: function () {
      let thatVue = this;

      thatVue.onSearchChange();
      this.decBusy();
    },    

    methods: {

      fullscreen: function () {
        if (screenfull.isEnabled) {
          screenfull.request();
        }
      }, 

      onthModalHide: function(evt) {
        let thatVue = this;
        
        if (evt.trigger === 'ok') {   
        }

        thatVue.$th.clearError();
      },

      isBusy: function() {
        let thatVue = this;

        return thatVue.busyCount > 0;
      },

      incBusy: function() {
        let thatVue = this;

        thatVue.busyCount = thatVue.busyCount + 1;

        if (thatVue.busyCount > 0) {
          thatVue.curCursor = 'progress';
        }        

        thatVue.disableDraggable = thatVue.busyCount > 0;        
      },

      decBusy: function() {
        let thatVue = this;

        thatVue.busyCount = thatVue.busyCount - 1;

        if (thatVue.busyCount <= 0) {
          thatVue.curCursor = 'default';
          document.body.style.cursor = 'default';
        }

        thatVue.disableDraggable = thatVue.busyCount > 0;
      },      

      setDirty: function(qguid, debounceMS, reFetch, evt) {
        // Enqueues a speific record (via qguid) for saving.
        // Needed for textarea autosave:  lets us debounce saving, while still triggering save on KeyUp
        let thatVue = this;

        // temporarily disable draggable
        // fetchWO and/or saveWO will incBusy / decBusy...which will properly set disableDraggable as needed
        thatVue.disableDraggable = true;

        if (!debounceMS && debounceMS !== 0) {
          //default to 3 seconds
          debounceMS = 3000;
        }

        let thisDirty = thatVue.dirtyQGUIDs.find((el) => el === qguid);
        if (!thisDirty) {
          thatVue.dirtyQGUIDs.push(qguid);
          thatVue.dirtyTimers.push({timer: setTimeout(thatVue.saveWO, debounceMS, qguid, reFetch, evt), qguid: qguid});
          //note:  timeout of 3000ms must be longer than debounce of 500ms in textarea       
        }    
      },

      switchWOList: function() {
        let thatVue = this;    
        
        if (thatVue.dirtyQGUIDs.length) {
          thatVue.dirtyTimers.forEach(o => clearTimeout(o.timer)); // clear out any pending dirty timers
          thatVue.saveWO(); // save any panding qguids
        }
        
        thatVue.data_WOs = [];
        thatVue.lastFetch_WOs = null;
        thatVue.fetchWOs();
      },

      toggleWODetail: function(qguid, evt) {
        // save reference to Vue object
        let thatVue = this;
        
        // find the corresponding WO  https://stackoverflow.com/questions/12462318/find-a-value-in-an-array-of-objects-in-javascript
        thatVue.data_ThisWO = thatVue.data_WOs.find((el) => el.qguid === qguid);
        //Note:  data_thisWO gets set to the most recently-expanded WO, but that is not
        //a guarantee that data_thisWO is the only one that may be edited by the user (as
        //multiple WO's could be expanded)
      },     

      onReleaseClick: function(qguid, evt) {
        let thatVue = this;
        thatVue.saveWO(qguid);
      },

      async onCompleteClick(qguid, evt){
        let thatVue = this;

        const boxResult = await this.$bvModal.msgBoxConfirm('Are you sure you want to complete this WO?  (This cannot be undone.)', {
          title: "Confirmation",
          size: "sm",
          buttonSize: "sm",
          okVariant: "danger",
          okTitle: "YES",
          cancelTitle: "NO",
          footerClass: "p-2",
          hideHeaderClose: false,
          centered: true
        });

        if (boxResult) {
          let thisWO = thatVue.data_WOs.find((el) => el.qguid === qguid);
          if (thisWO) {
            thisWO.do_PressCompleted = 1;
            thatVue.saveWO(qguid);
            thatVue.fetchWOs(null, true);
          }
        }
      },

      //onCompleteClick: function(qguid, evt) {
      //  let thatVue = this;      
        //thatVue.$th.raiseError('|Are you sure you want to complete this WO?  (This cannot be undone.)|1|Confirm Completion');   
        //thatVue.saveWO(qguid);          
      //},

      fetchWOs: function (qguid, reFetch) {
        // save reference to Vue object
        let thatVue = this;

        thatVue.incBusy();        

        thatVue.$th.sendAsync({
          url: "/async/" + thatVue.asyncResource_WOs,
          asyncCmd: thatVue.asyncCmd_WOs,
          lastFetchDate: thatVue.lastFetch_WOs,
          data: {listName: thatVue.curWOList}, //note: passes to @FormParams
          qguid: qguid,
          reFetch: reFetch,

          onResponse: function (rd, response, config) {
            // rd contains the response data split into an object (of name/value pairs)
            // (might have been returned as either a string of URL-encoded name/value
            // pairs, or as a JSON strong)

            // response contains the complete response object, in which .data contains
            // the raw data that was received.

            let thisObj;
            let thisData;
            let thisFetchDate;

            thisObj = {};
            thisData = [];
            thisFetchDate = null;

           if (!thatVue.$th.haveError(true)) {

              //  WOs
              if (rd["WOs"]) {
                thisObj = JSON.parse(rd["WOs"])[0];
                thisData = thisObj["JSONData"];
                thisFetchDate = thisObj["FetchDate"];

                if (config.reFetch) {
                  thatVue.data_WOs.length = 0; //clear out WO      
                }          

                if (thisData) {
                  thatVue.data_WOs = thatVue.$th.merge(
                          // string (optional): key field name with unique values to merge on
                          "qguid",
                          // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                          //'someIDValue'
                          thatVue.data_WOs,
                          thisData
                  );
                }
                thatVue.data_WOs = thatVue.$th.sortArray(
                        thatVue.data_WOs,
                        "Seq",
                        false //false=ascending, true=descending
                );
                

                if (thatVue.lastFetch_WOs) {
                  thatVue.lastFetch_WOs = thisFetchDate;
                } else {
                  thatVue.lastFetch_WOs = "1/1/1900";
                }

                if (thatVue && thatVue.data_thisWO && thatVue.data_thisWO.qguid) {
                  thatVue.data_ThisWO = thatVue.data_WOs.find((el) => el.qguid === thatVue.data_thisWO.qguid);                             
                }

                thatVue.onSearchChange();
              }

            }            
            thatVue.decBusy();
          },
        });
      },

      fetchData: function (forceOnError) {
        let thatVue = this;

        thatVue.incBusy();

        // clear out any old, stuck, in-progress async requests
        thatVue.$th.cancelAsync(moment().subtract(30, "s")); //cancel any request started more than 30 seconds ago

        // check th.loadingCount so we don't fire off too many simultaneous requests
        if (
                (forceOnError || !this.$th.theasParams.th$ErrorMessage) &&
                thatVue.$th.loadingCount < 5
        ) {
          if (thatVue.modalShowing === true) {
            thatVue.enableFetching = false;
          }

          if (thatVue.enableFetching === true) {
            thatVue.fetchWOs();
            // can add additional fetches here
          }
        }

        thatVue.decBusy();        
      },
    

      onChangePlan: function (qguid, evt) {
          let thatVue = this;  
          thatVue.setDirty(qguid);                         
      },

      saveWO: function (qguid, reFetch, evt) {
          // save reference to Vue object that can be used in async callbacks
          var thatVue = this;     
          
          if (qguid) {
            // qguid was specified.  We will save it, but first we remove any entries in the queue.
            let thisIndex = thatVue.dirtyQGUIDs.findIndex((el) => el === qguid);          
            if (thisIndex >= 0) {
                thatVue.$delete(thatVue.dirtyQGUIDs, thisIndex);  
                            
              let thisTimerIndex = thatVue.dirtyTimers.findIndex((el) => el.qguid === qguid);
              if (thisTimerIndex >= 0) {
                thatVue.$delete(thatVue.dirtyTimers, thisTimerIndex);
              }
            }            
          }
          else {
            // qguid not specified by caller.  See if there is a qguid in queue awaiting saving.
            qguid = thatVue.dirtyQGUIDs.pop()
          }

          while (qguid) {
            // we loop, to save all qguids in the queue

            let thisWO = thatVue.data_WOs.find((el) => el.qguid === qguid)

            if (thisWO) {
              thatVue.$forceUpdate();
            }

            thatVue.incBusy();     

            thatVue.$th.sendAsync({
              url: "/async/" + thatVue.asyncResource_WOs,
              asyncCmd: 'updateWO',
              data: {WO: thisWO}, //note: passes to @FormParams
              qguid: qguid,
              reFetch: reFetch,

              onResponse: function (rd, response, config) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.              

                  if (!thatVue.$th.haveError(true)) {

                    let thisIndex = thatVue.data_WOs.findIndex((el) => el.qguid === qguid)
                    if (thisIndex >= 0) {
                      thatVue.data_ThisWO = thatVue.data_WOs[thisIndex];

                      if
                        (
                          (thatVue.curWOList == 'Unscheduled' && thatVue.data_ThisWO.PlannedPress) ||
                          (thatVue.curWOList != 'Unscheduled' && thatVue.curWOList != thatVue.data_ThisWO.PlannedPress) ||
                          (thatVue.data_ThisWO.PressCompleted)
                        ){
                          thatVue.$delete(thatVue.data_WOs, thisIndex);
                          thatVue.data_ThisWO = {};                    
                        }
                    }

                    if (config && config.reFetch) {
                      thatVue.fetchWOs(config.qguid, config.reFetch);
                    }                    
                  }
                  
                  thatVue.decBusy();                    

                }
            });

            qguid = thatVue.dirtyQGUIDs.pop();

            //if (evt.type == 'keyup') {
              // Since event was keyup, this was for an autosave.  In the case of boostrapvue b-textarea
              // (and possibly other controls), a debounce is used.  This means that there may be additional
              // keystrokes that came in after the data in the model was updated by the control.

              // We are now some time after the event was fired (like 3000ms). But during that interval,
              // there could have been additional characters added...with no new "dirty" timer set (because
              // our timer was already set).

              // Now that we have popped the qguid, any future keystrokes will push another "dirty" timer:
              // that's good.

              // But suppose there are no more keystrokes, and the last keystroke came in while our
              // "dirty" timer was in queue, and just before that timer expired.  It is possible that the
              // textarea value wasn't yet updated with the characters from the final keystroke(s).  This
              // would mean that there will be no subsequent event triggered, and those characters would
              // never get saved.

              // So what we can do is add $nextTick(() => {...}) to do another update.

              // But we don't really want to do that every time we handle a keyup event, as that would
              // effectively process each keyup event TWICE.



              
            //}
          
          }
      },

      formatDate: function (thisDate, thisFormatStr) {
        //if (typeof thisDate === 'string' || thisDate instanceof String) {
        //    thisDate = thisDate.replace('T', ' ');
        //}
        let result = moment(thisDate).format(thisFormatStr);
        return result;
      },

      add: function () {
        this.list.push({name: "Juan"});
      },
      replace: function () {
        this.list = [{name: "Edgard"}];
      },
      clone: function (el) {
        return {
          name: el.name + " cloned",
        };
      },

      onDropWO: function (evt) {
        let thatVue = this;
        
        let newIndex = evt.moved.newIndex;

        if (thatVue.visibleWOs.length > 1) {
          if (newIndex == thatVue.visibleWOs.length - 1) {
            //moved to end of list
            thatVue.visibleWOs[newIndex - 1].NextQguid =  thatVue.visibleWOs[newIndex].qguid;
            thatVue.setDirty(thatVue.visibleWOs[newIndex - 1].qguid, 0, true);           
          }                    
          else {
            thatVue.visibleWOs[newIndex].NextQguid =  thatVue.visibleWOs[newIndex + 1].qguid;
            thatVue.setDirty(thatVue.visibleWOs[newIndex].qguid, 0, true);          
          }
        }   

      },

      doRepeatMove: function (qguid, evt) {
        let thatVue = this;

        thatVue.data_ThisWO = thatVue.data_WOs.find((el) => el.qguid === qguid);

        if (thatVue.data_ThisWO) {
          thatVue.data_ThisWO['RepeatMove'] = 1;

          thatVue.setDirty(qguid, 0, true, evt);
        }
      },
      
      doMoveFirst: function (qguid, evt) {
        let thatVue = this;

        thatVue.data_ThisWO = thatVue.data_WOs.find((el) => el.qguid === qguid);

        if (thatVue.data_ThisWO) {
          thatVue.data_ThisWO['MoveFirst'] = 1;

          thatVue.setDirty(qguid, 0, true, evt);
        }
      },      

      clickBookmark: function(qguid, evt) {
        let thatVue = this;

        if (thatVue.ignoreMouseup) return;


        let wo = thatVue.data_WOs.find((el) => el.qguid === qguid);        

        if (wo) {

          switch (wo.BookmarkCode) {
            case '1':
              wo.BookmarkCode = '2'
              break;
            case '2':
              wo.BookmarkCode = '3';
              break;
            case '3':
              wo.BookmarkCode = ''
              break;     
            default:
                wo.BookmarkCode = '1';  
          }

          thatVue.setDirty(wo.qguid, 0, false, evt);
        }

      },

      mousedownBookmark: function() {
        let thatVue = this;

        thatVue.ignoreMouseup = false;

        thatVue.mouseDownTimer = setTimeout(thatVue.clearBookmarks, 4000);
      },

      mouseupBookmark: function(evt) {
        let thatVue = this;

        if (thatVue.mouseDownTimer) {
          clearTimeout(thatVue.mouseDownTimer);
          thatVue.mouseDownTimer = null;
        }
      },

      clearBookmarks: function() {
        let thatVue = this;

        thatVue.ignoreMouseup = true;

        let ar = thatVue.visibleWOs.filter(wo => wo.BookmarkCode && wo.BookmarkCode.length > 0);

        ar.forEach(function(wo){
          wo.BookmarkCode = '';
          thatVue.setDirty(wo.qguid, 50, false);
        });
      },

      onSearchKeyUp: function(evt) {
        let thatVue = this;

        if (evt && (evt.key=="Enter" ||evt.key == 'Backspace'|| thatVue.searchTarget == "" )) {
          Vue.nextTick(function () {
            thatVue.onSearchChange();
          });
        }
        else {
          setTimeout(thatVue.onSearchChange, 100);
        }
      },

      onSearchChange: function(evt) {
        let thatVue = this;

        if (evt) {
          thatVue.searchTarget = thatVue.searchTarget + evt.key
        }

        if (thatVue.searchTarget) {
          thatVue.visibleWOs =
            thatVue.data_WOs.filter(wo => (
              (wo.WONumber && wo.WONumber.indexOf(this.searchTarget) >= 0) || 
              (wo.LinkedSONumber && wo.LinkedSONumber.indexOf(this.searchTarget) >= 0) ||
              (wo.ItemNumber && wo.ItemNumber.indexOf(this.searchTarget) >= 0) ||
              (wo.CustomerName && wo.CustomerName.toLowerCase().indexOf(this.searchTarget.toLowerCase()) >= 0)
            ));    
        }
        else {
          thatVue.visibleWOs = thatVue.data_WOs;
        }
      },

      applySOSeq: function() {

        let thatVue = this;

        thatVue.$th.sendAsync({
          url: "/async/" + thatVue.asyncResource_WOs,
          asyncCmd: 'applySeq',
          data: {
            listName: thatVue.curWOList,
            applySeqSOs: thatVue.soSeqText
          }, //note: passes to @FormParam

          onResponse: function (rd, response, config) {
              // rd contains the response data split into an object (of name/value pairs)
              // (might have been returned as either a string of URL-encoded name/value
              // pairs, or as a JSON strong)

              // response contains the complete response object, in which .data contains
              // the raw data that was received.              

              if (!thatVue.$th.haveError(true)) {
                thatVue.fetchWOs();              
              }
              
              thatVue.decBusy();                    
            }
        });


      }
    },
  };
</script>

<style>

  .fastscroll {
    overflow-y: scroll;
    -webkit-overflow-scrolling: touch;
  }

  .lastToMove {
    background-color: chocolate;
  }

  .bookmark {
    width: 10px;
    height: 100%;
    border-style: solid;
    border-width: 1px;
    border-color: lightgray;
  }

  .bookmark1 {
    width: 10px;
    height: 100%;    
    background-color:turquoise;
  }  

  .bookmark2 {
    width: 10px;
    height: 100%;    
    background-color:yellowgreen;
  }  

 .bookmark3 {
    width: 10px;
    height: 100%;    
    background-color:mediumpurple;
  }  
</style>
