<template>
<div style="height:100vh" class="mr-3">

  <b-row style="height: 15%">

    <b-col cols="3">
      <img src="/resources/SpaceAgeLogo.png">
    </b-col>

    <b-col cols="4">

      <div style="max-width: 225px">   

        <b-form-group label="Worker"
                    :label-for="'selWorker'">

          <b-form-select :id="'selWorker'"
                        :options="data_Workers"
                        v-model="curWorker"
                        size="sm"                        
          >
          </b-form-select>

        </b-form-group>   

      </div>         
      
    </b-col>

    <b-col cols="3">
      <div style="max-width: 200px">   

        <b-form-group label="Press"
                      :label-for="'ListName'" class="mb-0 pb-2">
          <b-form-select :id="'listName'"
                        v-model="curWOList" :options="woListNames" @change="switchWOList()"
                        size="sm"
                        >
          </b-form-select>
        </b-form-group>

          <h6 class="ml-1">[[ curWOList ]] (<span v-if="busy">Loading</span><span v-if="!busy">[[ data_WOs.length ]]</span><span>orders</span>)</h6>        

      </div>      
    </b-col>

    <b-col cols="1">
      <br />
      <b-button @click="fetchData()">Reload</b-button>
    </b-col>

    <b-col cols="1">
    </b-col>
  
  </b-row>  

  <b-row>
    <b-col cols="2" offset="10">
        <b-button class="mb-1" variant="outline-primary" @click="showHistory">Cut History</b-button>  
    </b-col>
  </b-row>  

  <div class="ml-3" style="height:65%" :style="{cursor: curCursor}">

    <b-row>
      <b-col>
          <Vue-Tabulator ref="tabulator" class="table-striped table-sm" v-model="data_WOs" :options="tab1Options" />
      </b-col>
    </b-row>

  </div>

  <div class="bottom">
    <b-row>

        <b-col cols="6">

          <b-row>

            <b-col>     
              <h5 style="font-size:calc(0.6em + 1.4vmin)">WO [[ curWOTable1.WONumber ]]</h5>
              <h6 style="font-size:calc(0.6em + 1vmin)">Remaining to cut:  [[ curWOTable1.Quantity - curWOTable1.GlassCutQuantity ]] (of [[ curWOTable1.Quantity ]] total)</h6>
            </b-col>      
          </b-row>      

          <b-row>
            <b-col cols="6">     
              <div style="max-width: 150px">          
              <b-form-group label="Active WO"
                            :label-for="'woTable1'">
                <b-form-select :id="'woTable1'"
                              :options="data_WOs"
                              v-model="curWOqguid_Table1"
                              @change="changeActiveWO('Table1', curWOqguid_Table1)"
                >
                </b-form-select>
              </b-form-group>
              </div>
            </b-col>

            <b-col cols="6">
              <div style="height:32px">
              </div>

              <b-button @click="completeCut('Table1')" variant="primary">Cut Complete</b-button>
            </b-col>            

          </b-row>
       
        </b-col>

        <b-col cols="2">
     
          <b-form-group label="Quantity (to print)"
                        :label-for="'printQuantity'">
            <b-form-input :id="'printQuantity'" :state="validCutQuantity"
                          v-model="printQuantity" size="sm" style="max-width: 75px"></b-form-input>
          </b-form-group>



          <b-button @click="print" variant="success" class="mt-3">Print Pallet Label</b-button>

          <div id="printMe" style="visibility: hidden">

              <p style="text-align:center">
                <img width=221 height=136 id="Picture 1" src="/resources/spaceage.jpg" alt="SpaceAge">
              </p>

              <h1 class="pb-5" style="text-align:center">Glass Pallet Label</h1>
              
                <h2 class="py-4">WO #: <span class="font-weight-bold">[[ curWO.WONumber ]]</span></h2>
                
                <h2 class="py-4">Customer: <span class="font-weight-bold">[[ curWO.CustomerName ]]</span></h2>

                <h2 class="py-4">Description: <span class="font-weight-bold">[[ curWO.GlassSpecs ]]</span></h2>
                
                <h2 class="py-4">Off-Press Dimensions: <span class="font-weight-bold">[[ curWO.DimThickness_OffPress ]] X [[ curWO.DimWidth_OffPress ]] X [[ curWO.DimLength_OffPress ]]</span></h2>
                              
                <h2 class="py-4">Quantity: <span class="font-weight-bold">[[ printQuantity ]]</span></h2>
                            
                <h2 class="py-4">Cut By: <span class="font-weight-bold">[[ curWorkerAbbrev]]</span></h2>                         
                
                <h2 class="py-4">Date: <span class="font-weight-bold">[[ curDate ]]</span></h2>        

          </div>              

        </b-col>
    </b-row>
  </div>

  <b-modal id="thModal" ref="thModal" @hide="onthModalHide" hide-footer>
    <template #modal-title>
      [[ theasLastError.msgTitle ]]
    </template>
    <div class="d-block text-center">
      <h3>[[ theasLastError.msgFriendly ]]</h3>
      <h5>[[ theasLastError.msgTech ]]</h5>        
    </div>
  </b-modal>


  <b-modal id="CutHistoryModal" ref="CutHistoryModal"  size="huge" @show="onShowCutHistory" @hide="onHideCutHistory($event)" hide-footer>
    <template #modal-title>
      <h4>Cut History</h4>
    </template>

  

    <div class="d-block">

      <Vue-Tabulator ref="tabuCutHistory" class="table-striped table-sm" v-model="data_Cuts" :options="tabCutHistOpt" @row-click="onHistoryRowClick" />            

    </div>

  </b-modal>

  <b-modal id="WOCutModal" ref="WOCutModal" @show="onShowWOCut" @ok="onCloseWOCut(curWO.qguid, $event)" hide-footer>
    <template #modal-title>
      <h4>WO [[ curWO.WONumber ]] Glass Cuts</h4>
    </template>

    <div class="d-block">
      
      <b-row>      
        <b-col>          
          <b-form-group label="Quantity"
                        :label-for="'cutQuantity'">
            <b-form-input :id="'cutQuantity'" :state="validCutQuantity"
                          v-model="curCut.Quantity" size="sm"></b-form-input>
          </b-form-group>
        </b-col>
      </b-row>

      <b-row>      
        <b-col>   
          <b-form-group label="Notes"
                        :label-for="'cutNotes'">
            <b-form-textarea :id="'cutNotes'" debounce="300"
                            v-model="curCut.Notes" rows="3" max-rows="3">   
            </b-form-textarea>                                                   
          </b-form-group>           
        </b-col>
      </b-row>      

      <b-row>
        <b-col>
          <h5>Cut By: [[ curCut.WorkerName ]]</h5>
          <p class="ital">[[ formatDate(curCut.DateFinished, 'dd MM/DD HH:mm') ]] </p>
        </b-col>
      </b-row>

    </div>
  </b-modal>  

</div>
</template>

<script>

  export default {
    delimiters: ["[[", "]]"],


    data() {
      return {

            tab1Options: {
              responsiveLayout: 'collapse', // enable responsive layouts
              height: '64vh', //with responsiveCollapse we need to specify an absolute height
              layout: 'fitDataFill',
              //layout: 'fitColumns',
              responsiveLayoutCollapseStartOpen: false,
              resizableColumns: true,

              columns: [
                {title: '', responsive: 0, formatter:"responsiveCollapse", headerSort:false},                   
                //{title: '', field:"StatusColor", formatter:"color"},
                {title: '', field:"TableNo",
                  formatter: function(cell, formatterParams, onRendered){
                    let thisVal = cell.getValue();
                    let thisColor = '#FFFFFF'

                    if (thisVal == 'Table1') {
                      // primary
                      thisColor = "#007bff";
                    }                           
                    else if (thisVal == 'Table2') {
                      // warning
                      thisColor = "#ffc107";
                    }

                    cell.getElement().style.backgroundColor = thisColor;

                    return thisVal;
                    },
                  formatterParams: {formatStr: "dd MM/DD"}
                },                              
                {title: 'WO', field: 'WONumber', responsive: 0},        
                {title: 'Qty Remain', field: 'QtyRemaining', responsive: 0},
                {title: 'Qty Needed', field: 'Quantity', responsive: 3},                
                {title: 'Qty Shot', field: 'CurrentShotCount', responsive: 4},

                {title: 'Off Press Date', field: 'DateReqOffPress', 
                  formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);},
                  formatterParams: {formatStr: "dd MM/DD"}
                },

                {title: 'Hours Remain', field: 'PressHoursRemain'},

                {title: 'Thick', field: 'DimThickness_Finished'},
                {title: 'Thick OP', field: 'DimThickness_OffPress'},
                {title: 'Width OP', field: 'DimWidth_OffPress'},
                {title: 'Length Glass', field: 'GlassCutLength'},

                {title: 'Glass', field: 'GlassSpecs', width: '5em', formatter: 'textarea'},  
                {title: 'Shim Layup', field: 'ShimLayup', width: '7em', formatter: 'textarea'},
                {title: 'Glass Layers', field: 'MoldGlassLayers', responsive: 2},        

                {title: 'Foam', field: 'FoamSystem', responsive: 2},
                {title: 'Foam Grams', field: 'Weight_Foam'},
                {title: 'Set Time', field: 'SetTimeSeconds'},   
                
                {title: 'Weight OP', field: 'Weight_OffPress'},                
                {title: 'Weight Sanded', field: 'Weight_Sanded'},                

                {title: 'Item', field: 'ItemNumber', responsive: 3, minWidth: 150},
                {title: 'Customer', field: 'CustomerName', responsive: 3, minWidth: 175},
                {title: 'SO', field: 'LinkedSONumber', responsive: 3},                

                {title: 'Commit Date', field: 'EstShipDate', responsive: 3,
                  formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);},
                  formatterParams: {formatStr: "MM/DD"}
                },   

                //{title: 'Finish', field: 'SurfaceFinish', responsive: 4, minWidth: 150},


                {title: 'Notes', field: 'Notes', responsive: 0, minWidth: 175}
                                                                 
              ],
            },

            tabCutHistOpt: {

              responsiveLayout: 'hide', // enable responsive layouts
              height: '40vh', //with responsiveCollapse we need to specify an absolute height
              layout: 'fitDataFill',
              responsiveLayoutCollapseStartOpen: false,
              //resizableColumns: false,
              columns: [
                                      
                //{title: '', responsive: 0, formatter:"responsiveCollapse", headerSort:false},                                          
                {title: 'WO', field: 'WONumber', responsive: 0, headerSort:false},
                {title: 'Cut', field: 'GlassCutSeq', responsive: 0, headerSort:false},
                {title: 'Cut By', field: 'WorkerName', responsive: 0, headerSort:false}, 
                {title: 'Shift', field: 'Shift,', responsive: 0, headerSort:false},                                
                
                {title: 'Time', field: 'DateFinished', responsive: 0, headerSort:false, 
                  formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);},
                  formatterParams: {formatStr: "dd MM/DD HH:mm"}
                },

                {title: 'Quantity', field: 'Quantity', responsive: 0, headerSort:false},                

                {title: 'Notes', field: 'Notes', responsive: 0, minWidth: 175, headerSort:false},

                {title: 'qguid', field: 'qguid', visible: false}                
                                                                 
              ],
            },

        theasParams: {},
        theasLastError: {},
                
        dataRefreshInterval: 15 * 60,  //auto-refresh, in seconds
        enableFetching: true,
        today: moment().toDate(),
        busyCount: 1,
        curCursor: 'progress',
        dirtyQGUIDs: [], // list of qguids that need to be saved
        dirtyTimers: [], // timers for pending saves of qguids

        overlayVisible: false,

        drag: null, 

        // Dynamic data will be fetched asynchronously
        data_WOs: [],
        data_Cuts: [],
        data_Workers: [],

        lastFetch_WOs: null,
        lastFetch_Workers: null,

        asyncResource_WOs: 'sched/sched_App.vue',
        asyncCmd_WOs: 'fetchWOsForPress',
        asyncCmd_Workers: 'fetchWorkers',

        pressCodes: ['N', 'NW', 'S', 'W'],

        woListNames: ['N', 'NW', 'S', 'W'],
        curWOList: 'N',

        curWOqguid_Table1: null,
        curWOqguid_Table2: null,   
        curWorker: null,     

        curWO: {},
        curWOTable1: {},
        curWOTable2: {},

        curCut: {},

        printQuantity: 1,

        thisWO_EstShipDate: null, // object for datepicker
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
      thatVue.fetchData(true);
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

      validCutQuantity : function() {
        return this.isNumQty(this.curCut.Quantity);
      },

      curWorkerName : function() {
        return this.workerName(this.curWorker);
      },
      curWorkerAbbrev: function() {
        return this.workerAbbrev(this.curWorker);
      },      

      curDate : function() {
        return this.formatDate(null, 'ddd MM/DD/YYYY HH:mm');
      }

    },

    methods: {

      fullscreen: function () {
        if (screenfull.isEnabled) {
          screenfull.request();
        }
      },

      async print () {
        let thatVue = this;

        if (!thatVue.curWorker) {
            //TechnicalMessage|FriendlyMessage|ShowTech?|Title
            thatVue.$th.raiseError('|Please select the worker that is currently cutting glass.|1|No worker selected!');
        }
        
        else {

          thatVue.curWO = thatVue.curWOTable1;

          // Pass the element id here
          await this.$htmlToPaper('printMe');
        }
      },

      formatDate: function(dt, fmt) {

        if (!dt) {
          dt = moment().format();
        }

        if (!fmt) {
          fmt = 'MM/DD/YYYY'
        }
        return moment(dt).format(fmt)
      },

      onShowCutHistory: function() {
        let thatVue = this;
      },

      onHideCutHistory: function(qguid, evt) {
        let thatVue = this; 
      },

      onShowWOCut: function() {
        let thatVue = this;
      },

      onCloseWOCut: function(qguid, evt) {
        let thatVue = this;

        //Call setDirty if you want to defer the submit for a few seconds.
        //thatVue.setDirty(qguid); 

        //Or call saveCut if you want to immediately submit.
        thatVue.saveCut(qguid);      
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

          // set timer for auto-refresh
          if (thatVue.dataRefreshInterval) {
            setTimeout(thatVue.fetchData, thatVue.dataRefreshInterval * 1000);    
          }      
        }
      },      

      setDirty: function(qguid) {
        // Enqueues a speific record (via qguid) for saving.
        // Needed for textarea autosave:  lets us debounce saving, while still triggering save on KeyUp
        let thatVue = this;

        let thisDirty = thatVue.dirtyQGUIDs.find((el) => el === qguid);
        if (!thisDirty) {
          thatVue.dirtyQGUIDs.push(qguid);
          thatVue.dirtyTimers.push({timer: setTimeout(thatVue.saveCut, 3000, qguid), qguid: qguid});
          //note:  timeout of 3000 must be longer than debounce of 1000 in textarea       
        }    
      },


      onHistoryRowClick: function(e, row) {
        let thatVue = this;

        thatVue.curCut = thatVue.data_Cuts.find((el) => el.qguid === row.getData().qguid);
                              
        thatVue.$bvModal.show('WOCutModal'); 
      },

      switchWOList: function() {
        let thatVue = this;    
        
        if (thatVue.dirtyQGUIDs.length) {
          thatVue.dirtyTimers.forEach(o => clearTimeout(o.timer)); // clear out any pending dirty timers
          thatVue.saveCut(); // save any panding qguids
        }
        
        thatVue.data_WOs = [];
        thatVue.lastFetch_WOs = null;
        thatVue.fetchWOs();
      },

      fetchWorkers: function (workerType) {
        // save reference to Vue object
        let thatVue = this;

        thatVue.incBusy();        

        thatVue.$th.sendAsync({
          url: "/async/" + thatVue.asyncResource_WOs,
          asyncCmd: thatVue.asyncCmd_Workers,
          lastFetchDate: thatVue.lastFetch_Workers,
          data: {workerType: workerType}, //note: passes to @FormParams

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
              if (rd["Workers"]) {
                thisObj = JSON.parse(rd["Workers"])[0];
                thisData = thisObj["JSONData"];
                thisFetchDate = thisObj["FetchDate"];

                
                if (thisData) {
                  thatVue.data_Workers = thatVue.$th.merge(
                          // string (optional): key field name with unique values to merge on
                          "qguid",
                          // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                          //'someIDValue'
                          thatVue.data_Workers,
                          thisData
                  );
                }
                thatVue.data_Workers = thatVue.$th.sortArray(
                        thatVue.data_Workers,
                        "Seq",
                        false //false=ascending, true=descending
                );

                //copy some properties so data_WOs can be used as options for selects
                thatVue.data_Workers.forEach(op => {
                  op.value = op.qguid;
                  op.text = op.Worker;
                });                         

                if (thatVue.lastFetch_WOs) {
                  thatVue.lastFetch_Workers = thisFetchDate;
                } else {
                  thatVue.lastFetch_Workers = "1/1/1900";
                }           

              }

            }
            thatVue.decBusy();
          },
        });
      },

      fetchWOs: function (qguid, reFetch) {
        // save reference to Vue object
        let thatVue = this;

        //for now, force a full refresh (not incremental) so that
        //we can remove stale WOs
        thatVue.lastFetch_WOs = null;
        reFetch = true;

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

                //copy some properties so data_WOs can be used as options for selects
                thatVue.data_WOs.forEach(wo => {
                  wo.value = wo.qguid;
                  wo.text = wo.WONumber;
                });                

                if (thatVue.lastFetch_WOs) {
                  thatVue.lastFetch_WOs = thisFetchDate;
                } else {
                  thatVue.lastFetch_WOs = "1/1/1900";
                }

                if (thatVue.data_WOs.length > 0) {
                  thatVue.curWO = thatVue.data_WOs[0];
                }


                if (thatVue && thatVue.data_WOs && thatVue.data_WOs.length > 0) {
                    thatVue.curWOTable1= thatVue.data_WOs[0];
                    thatVue.curWOTable1.TableNo = 'Table1';
                    thatVue.curWOqguid_Table1 = thatVue.curWOTable1.qguid
                    if (thatVue.data_WOs.length > 1) {
                      thatVue.curWOTable2= thatVue.data_WOs[1]; 
                      thatVue.curWOTable2.TableNo = 'Table2';
                      thatVue.curWOqguid_Table2 = thatVue.curWOTable2.qguid;                                           
                    }
                }             

              }


              //  Cuts
              if (1==1 && rd["WOGlassCuts"]) {
                thisObj = JSON.parse(rd["WOGlassCuts"])[0];
                thisData = thisObj["JSONData"];
                thisFetchDate = thisObj["FetchDate"];

                if (config.reFetch) {
                  thatVue.data_Cuts.length = 0; //clear out WO      
                }          

                if (thisData) {
                  thatVue.data_Cuts = thatVue.$th.merge(
                          // string (optional): key field name with unique values to merge on
                          "qguid",
                          // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                          //'someIDValue'
                          thatVue.data_Cuts,
                          thisData
                  );

                  // remove any cuts that don't have a qguid (i.e. recently-added temporary cuts that should now have been received with a qguid
                  thatVue.data_Cuts = thatVue.data_Cuts.filter((qguid) => true ? qguid : false)

                }
                thatVue.data_Cuts = thatVue.$th.sortArray(
                        thatVue.data_Cuts,
                        "DateStarted",
                        true //false=ascending, true=descending
                );

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
            thatVue.fetchWorkers('GlassCutter');
            // can add additional fetches here
          }
        }

        thatVue.decBusy();        
      },
    

      onChangePlan: function (qguid, event) {
          let thatVue = this;  
          thatVue.setDirty(qguid);                         
      },

      changeActiveWO: function (tableCode, qguid) {
        let thatVue = this; 

        thatVue.curWO = thatVue.data_WOs.find((el) => el.qguid === qguid);

        if (tableCode == 'Table1') {
          thatVue.curWOTable1 = thatVue.curWO;
        }

        else if (tableCode == 'Table2') {
          thatVue.curWOTable2 = thatVue.curWO;    
        }


      },

       nction() {        
        let thatVue = this;

        thatVue.$bvModal.show('CutHistoryModal');         
        //thatVue.$refs.tabuCutHistory.redraw(true);       
        //thatVue.$refs.tabuCutHistory.setSort({column:"DateFinished", dir:"desc"});

        setTimeout(function(){
        //Vue.nextTick(function () {     
            //need to refdraw the table after the modal is shown.  nextTick does not work, but setTimeout does work.     
            thatVue.$refs.tabuCutHistory.tabulatorInstance.redraw(true);
        //});            
        }, 100);        
      },

      completeCut: function(tableCode) {
          var thatVue = this;

          if (tableCode == 'Table1') {
            thatVue.curWO = thatVue.curWOTable1
          }
          else if (tableCode == 'Table2') {
            thatVue.curWO = thatVue.curWOTable2
          }

          if (!thatVue.curWorker) {
            //TechnicalMessage|FriendlyMessage|ShowTech?|Title
            thatVue.$th.raiseError('|Please select the worker that is currently cutting glass.|1|No worker selected!');
          }
          else {
            thatVue.curCut = {};
            thatVue.curCut.qguidWO = thatVue.curWO.qguid;
            thatVue.curCut.WONumber = thatVue.curWO.WONumber;            
            thatVue.curCut.Worker = thatVue.curWorker;        
            thatVue.curCut.WorkerName =  thatVue.workerName(thatVue.curWorker);
            thatVue.$bvModal.show('WOCutModal');            
          }
      },

      saveCut: function (qguid, event) {
          // save reference to Vue object that can be used in async callbacks
          var thatVue = this;

          //note that qguid is for the WO (not the cut)
          
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

          if (!qguid && thatVue.curCut.qguidWO) {
            qguid = thatVue.curCut.qguidWO
          }

          while (qguid) {
            // we loop, to save all qguids in the queue

            let thisWO = thatVue.data_WOs.find((el) => el.qguid === qguid)

            thatVue.$th.sendAsync({
              url: "/async/" + thatVue.asyncResource_WOs,
              asyncCmd: 'completeCut',              
              data: {WO: thisWO, Cut: thatVue.curCut}, //note: passes to @FormParams

              onResponse: function (rd, response) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.              

                let cutResp= {};         

                if (!thatVue.$th.haveError(true)) {

                  //  CutResponse
                  if (rd["CutResponse"]) {
                    cutResp = JSON.parse(rd["CutResponse"]);
                  }

                  if (cutResp) {

                    let thisIndex = thatVue.data_WOs.findIndex((el) => el.qguid === cutResp.qguidWO)
                    if (thisIndex >= 0) {
                      thatVue.data_WOs[thisIndex].GlassCutQuantity = cutResp.GlassCutQuantity;
                    }
                    

                    if (cutResp.qguid == thatVue.curCut.qguid) {
                      // updating existing cut

                      let thisIndex = thatVue.data_Cuts.findIndex((el) => el.qguid === cutResp.qgui)
                      if (thisIndex >= 0) {
                        thatVue.data_Cuts[thisIndex] = thatVue.curCut;
                      }

                    }
                    else {
                      // new cut
                      if (!thatVue.curCut.qguid) {
                        thatVue.curCut.qguid = cutResp.qguid
                        thatVue.curCut.WONumber = cutResp.WONumber
                      }
                      thatVue.curCut.GlassCutSeq = cutResp.GlassCutSeq
                      thatVue.curCut.Worker = cutResp.Worker
                      thatVue.curCut.WorkerName = cutResp.WorkerName
                      thatVue.curCut.Shift = cutResp.Shift

                      thatVue.data_Cuts.unshift(thatVue.curCut);
                    }                    

                  }

                 thatVue.curCut = {};

                }
              }
            });
            
            qguid = thatVue.dirtyQGUIDs.pop();
          
          }
      
      },

      workerName: function(qguid) {
        if (!qguid) {
          qguid = this.curWorker;
        }

        let thisWorker = this.data_Workers.find((el) => el.qguid == qguid);

        let thisName = null;

        if (thisWorker) {
          thisName = thisWorker.Worker;
        }
        
        return thisName
      },

      workerAbbrev: function(qguid) {
        if (!qguid) {
          qguid = this.curWorker;
        }

        let thisWorker = this.data_Workers.find((el) => el.qguid == qguid);

        let thisAbbrev = null;

        if (thisWorker) {
          thisAbbrev = thisWorker.WorkerAbbreviation;
        }
        
        return thisAbbrev
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

      isNumQty : function(thisVal) {
        let isValid = (thisVal && !isNaN(thisVal) && thisVal > 0 && thisVal < 5000);
        return isValid;
      }      
  
    },
  };
</script>

<style>

  .fastscroll {
    overflow-y: scroll;
    -webkit-overflow-scrolling: touch;
  }

  .noscroll {
    overflow-y: hidden;
  }  

  .fullheight {
    height: 100vh; /* Fallback for browsers that do not support Custom Properties */
    height: calc(var(--vh, 1vh) * 100);
  }  

  .tabulator { font-size: .85em; }

  .tabulator-row .tabulator-cell{
      padding:2px 2px;
  }

  .bottom {
    position: fixed;
    width: 100%;
    height: 150px;
    bottom: 0;
    padding-left: 10px;
    padding-right: 10px;
    background-color: #BDB76B;
  }

  .ital {
    font-style:italic;
    font-size:smaller;
  }

</style>
