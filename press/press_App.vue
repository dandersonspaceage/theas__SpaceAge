<template>
<div style="height:100%" class="mr-3">
    <b-row style="height: 15%">
      <b-col>
        <img src="/resources/SpaceAgeLogo.png">
      </b-col>

      <b-col>
        <b-form-group label="Press"
                      :label-for="'ListName'">
          <b-form-select :id="'listName'"
                        v-model="curWOList" :options="woListNames" @change="switchWOList()"
                        size="sm"></b-form-select>
        </b-form-group>

          <h6>[[ curWOList ]] (<span v-if="busy">Loading</span><span v-if="!busy">[[ data_WOs.length ]]</span><span>orders</span>)</h6>        
      </b-col>
    
    </b-row>    

  <div class="ml-3" style="height:85%" :style="{cursor: curCursor}">

    <b-row style="height: 80%">
      <b-col>
          <Vue-Tabulator ref="tabulator" class="table-striped table-sm" v-model="data_WOs" :options="tab1Options" />
      </b-col>
    </b-row>



    <b-row style="height: 20%; background-color: #BDB76B">

        <b-col cols="2">
          <h3>Working on: xxxx  5 of 28</h3>
          <b-button size="lg" variant="success">Completed Board</b-button>
        </b-col>

        <b-col>
          Another col
        </b-col>



    </b-row>

    <b-modal id="thModal" ref="thModal" @hide="onthModalHide" hide-footer>
      <template #modal-title>
        [[ theasLastError.msgTitle ]]
      </template>
      <div class="d-block text-center">
        <h3>[[ theasLastError.msgFriendly ]]</h3>
        <h5>[[ theasLastError.msgTech ]]</h5>        
      </div>
    </b-modal>

  </div>

</div>
</template>

<script>

  export default {
    delimiters: ["[[", "]]"],


    data() {
      return {

            tab1Options: {
              responsiveLayout: 'collapse', // enable responsive layouts
              height: '68vh', //with responsiveCollapse we need to specify an  absolute height
              layout: 'fitDataFill',
              responsiveLayoutCollapseStartOpen: false,
              resizableColumns: false,

              columns: [
                {title: '', responsive: 0, formatter:"responsiveCollapse", headerSort:false},                   
                {title: 'WO', field: 'WONumber', responsive: 0},                  
                {title: 'SO', field: 'LinkedSONumber', responsive: 0},
                {title: 'Qty', field: 'Quantity', responsive: 0},
                {title: 'QtyShot', field: 'CurrentShotCount', responsive: 0},
                {title: 'CommitDate', field: 'CommitDate', formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);}, formatterParams: {formatStr: "MM/DD"}},
                {title: 'Item', field: 'ItemNumber'},
                {title: 'Customer', field: 'CustomerName'},
                {title: 'ThicknessOffPress', field: 'DimThickness_OffPress'},
                {title: 'WidthOffPress', field: 'DimWidth_OffPress'},
                {title: 'LengthOffPress', field: 'DimLength_OffPress'},
                {title: 'Foam', field: 'FoamSystem', responsive: 2},
                {title: 'GlassSeries', field: 'GlassSeries', responsive: 2},
                {title: 'Finish', field: 'SurfaceFinish', responsive: 2},
                {title: 'ShimLayup', field: 'ShimLayup', responsive: 2},
                {title: 'MoldGlassLayers', field: 'MoldGlassLayers'},
                {title: 'ShotWeight', field: 'Weight_OffPress'},
                {title: 'FoamGrams', field: 'Weight_Foam'},
                {title: 'Notes', field: 'Notes', responsive: 0, width:'20%'},
                                                                 
              ],
            },

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

        drag: null, 

        // Dynamic data will be fetched asynchronously
        data_WOs: [],

        lastFetch_WOs: null,

        asyncResource_WOs: 'sched/sched_App.vue',
        asyncCmd_WOs: 'fetchWOsForPress',

        pressCodes: ['N', 'NW', 'S', 'W'],

        woListNames: ['N', 'NW', 'S', 'W'],
        curWOList: 'N',

        data_ThisWO: {},
        thisWO_CommitDate: null, // object for datepicker
      };
    },

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

      // perform the initial fetch of data
      this.fetchData(true);
    },

    // method executed when the Vue object is mounted / done rendering
    mounted: function () {

      //const tabulatorInstance = this.$refs.tabulator.getInstance();

      // perform the initial fetch of data
      this.decBusy();
    },    


    computed: {
      busy : function () {
        return this.busyCount > 0;
      }, 

    },

    methods: {

      fullscreen: function () {
        if (screenfull.isEnabled) {
          screenfull.request();
        }
      }, 

      onthModalHide: function() {
        let thatVue = this;

        thatVue.$th.clearError();
      },

      incBusy: function() {
        let thatVue = this;

        thatVue.busyCount = thatVue.busyCount + 1;

        if (thatVue.busyCount > 0) {
          thatVue.curCursor = 'progress';
        }        
      },

      decBusy: function() {
        let thatVue = this;

        thatVue.busyCount = thatVue.busyCount - 1;

        if (thatVue.busyCount <= 0) {
          thatVue.curCursor = 'default';
          document.body.style.cursor = 'default';
        }
      },      

      setDirty: function(qguid) {
        // Enqueues a speific record (via qguid) for saving.
        // Needed for textarea autosave:  lets us debounce saving, while still triggering save on KeyUp
        let thatVue = this;

        let thisDirty = thatVue.dirtyQGUIDs.find((el) => el === qguid);
        if (!thisDirty) {
          thatVue.dirtyQGUIDs.push(qguid);
          thatVue.dirtyTimers.push({timer: setTimeout(thatVue.saveWO, 3000, qguid), qguid: qguid});
          //note:  timeout of 3000 must be longer than debounce of 1000 in textarea       
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

      toggleWODetail: function(qguid, event) {
        // save reference to Vue object
        let thatVue = this;
        
        // find the corresponding WO  https://stackoverflow.com/questions/12462318/find-a-value-in-an-array-of-objects-in-javascript
        thatVue.data_ThisWO = thatVue.data_WOs.find((el) => el.qguid === qguid);
        //Note:  data_thisWO gets set to the most recently-expanded WO, but that is not
        //a guarantee that data_thisWO is the only one that may be edited by the user (as
        //multiple WO's could be expanded)
      },     

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
    

      onChangePlan: function (qguid, event) {
          let thatVue = this;  
          thatVue.setDirty(qguid);                         
      },

      saveWO: function (qguid, event) {
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
            // qguid not specified.  See if there is a qguid in queue awaiting saving.
            qguid = thatVue.dirtyQGUIDs.pop()
          }

          while (qguid) {
            // we loop, to save all qguids in the queue

            let thisWO = thatVue.data_WOs.find((el) => el.qguid === qguid)

            thatVue.$th.sendAsync({
              url: "/async/" + thatVue.asyncResource_WOs,
              asyncCmd: 'updateWO',
              data: {WO: thisWO}, //note: passes to @FormParams

              onResponse: function (rd, response) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.              

                  let thisIndex = thatVue.data_WOs.findIndex((el) => el.qguid === qguid)
                  if (thisIndex >= 0) {
                    thatVue.data_ThisWO = thatVue.data_WOs[thisIndex];

                    if
                      (
                        (thatVue.curWOList == 'Unscheduled' && thatVue.data_ThisWO.PlannedPress) ||
                        (thatVue.curWOList != 'Unscheduled' && thatVue.curWOList != thatVue.data_ThisWO.PlannedPress)
                      ){
                        thatVue.$delete(thatVue.data_WOs, thisIndex);
                        thatVue.data_ThisWO = {};                    
                      }
                  }

                }
            });

            qguid = thatVue.dirtyQGUIDs.pop();
          
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

        if (thatVue.data_WOs.length > 1) {
          if (newIndex == thatVue.data_WOs.length - 1) {
            //moved to end of list
            thatVue.data_WOs[newIndex - 1].NextQguid =  thatVue.data_WOs[newIndex].qguid;
            thatVue.setDirty(thatVue.data_WOs[newIndex - 1].qguid);           
          }                    
          else {
            thatVue.data_WOs[newIndex].NextQguid =  thatVue.data_WOs[newIndex + 1].qguid;
            thatVue.setDirty(thatVue.data_WOs[newIndex].qguid);          
          }
        }   
      }     
    },
  };
</script>

<style>
  h1 {
    color: blue;
  }

  p {
    color: green;
  }

  .fastscroll {
    overflow-y: scroll;
    -webkit-overflow-scrolling: touch;
  }

  .noscroll {
    overflow-y: hidden;
  }  
</style>
