<template>

<div style="height:100vh" class="mr-3">

  <b-row style="height: 15%">

    <b-col cols="3">
      <img src="/resources/SpaceAgeLogo.png">
    </b-col>

    <b-col cols="4">

      <div style="max-width: 225px">   

        <b-form-group label="Operator"
                    :label-for="'selWorker'">

          <b-form-select :id="'selWorker'"
                        :options="data_Workers"
                        v-model="curWorkerQGUID"
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
                        :disabled="lockPressSelection"
                        v-model="curWOListCode" :options="woListNames" @change="switchWOList()"
                        size="sm"
                        >
          </b-form-select>
        </b-form-group>

          <h6 class="ml-1">[[ curWOListCode ]] (<span v-if="busy">Loading</span><span v-if="!busy">[[ data_WOs.length ]]</span><span>orders</span>)</h6>        

      </div>      
    </b-col>

    <b-col cols="1">
      <br />
      <b-button class="mb-1" variant="outline-primary" @click="showHistory">Shot History</b-button>
    </b-col>
    
    <b-col cols="1">
      <br />
      <b-button @click="fetchData()">Reload</b-button>
    </b-col>
  
  </b-row>  

  <b-row class="ml-3" style="height:65%" :style="{cursor: curCursor}">
    <b-col>
        <Vue-Tabulator ref="tabulator" class="table-striped table-sm" v-model="data_WOs" :options="tab1Options" />
    </b-col>
  </b-row>

  <b-row class="bottom">

      <b-col xs="*">

        <b-row>
          <b-col>
            <b-row>
              <b-col cols="4">
                <h4 style="font-size:calc(1em + 1vmin)">Table 2</h4>
              </b-col>
              <b-col cols="8">
                <h5>00:22:00 elapsed</h5>
              </b-col>
            </b-row>
          </b-col>

          <b-col>     
            <h5 style="font-size:calc(0.6em + 1.4vmin)">WO [[ (curWOTable2) ? curWOTable2.WONumber : 'none']]</h5>
            <h6 style="font-size:calc(0.6em + 1vmin)">#[[ (curWOTable2) ? Number(curWOTable2.CurrentShotCount) + 1 : '0']] of [[ (curWOTable2) ? curWOTable2.Quantity : '0']]</h6>
          </b-col>      
        </b-row>      

        <b-row>
          <b-col cols="6">     
            <div style="max-width: 150px">          
              <b-form-group label="Active WO"
                            :label-for="'woTable2'">
                <b-form-select :id="'woTable2'"
                              :options="data_WOs"
                              v-model="curWOqguid_Table2"
                              @change="changeActiveWO('Table2', curWOqguid_Table2)"
                >
                </b-form-select>
              </b-form-group>
              <h6>Last set time:</h6>
            </div>
          </b-col>

          <b-col cols="6">
            <div style="height:32px">
            </div>

            <b-button @click="completeShot('Table2')" variant="primary">Shot</b-button>
          </b-col>            

        </b-row>
      
      </b-col>

      <b-col xs="*">

        <b-row>
          <b-col>
            <h4 style="font-size:calc(1em + 1vmin)">Table 1</h4>
          </b-col>

          <b-col>     
            <h5 style="font-size:calc(0.6em + 1.4vmin)">WO [[ (curWOTable1) ? curWOTable1.WONumber : 'none']]</h5>
            <h6 style="font-size:calc(0.6em + 1vmin)">#[[ (curWOTable1) ? Number(curWOTable1.CurrentShotCount) + 1 : '0']] of [[ (curWOTable1) ? curWOTable1.Quantity : '0']]</h6>              
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

            <b-button @click="completeShot('Table1')" variant="warning">Shot</b-button>
          </b-col>            

        </b-row>
      
      </b-col>


  </b-row>


  <b-modal id="thModal" ref="thModal" @hide="onthModalHide">
    <template #modal-title>
      [[ theasLastError.msgTitle ]]
    </template>
    <div class="d-block text-center">
      <h3>[[ theasLastError.msgFriendly ]]</h3>
      <h5>[[ theasLastError.msgTech ]]</h5>        
    </div>
  </b-modal>


  <b-modal id="ShotHistoryModal" ref="ShotHistoryModal"  size="huge" @show="onShowShotHistory" @hide="onHideShotHistory($event)">
    <template #modal-title>
      <h4>Shot History</h4>
    </template>

    <div class="d-block">
      <Vue-Tabulator ref="tabuShotHistory" class="table-striped table-sm" v-model="data_Shots" :options="tabShotHistOpt" @row-click="onHistoryRowClick" />            
    </div>

  </b-modal>

  <b-modal id="WOQualityModal" ref="WOQualityModal" @show="onShowWOQuality" @hide="onHideWOQuality(curShot.qguid, $event)" :static="true">
    <template #modal-title>
      <h4>WO [[ curShot.WONumber ]] <span v-if="curShot.qguid"><span class="text-decoration-underline">Shot #[[ curShot.ShotNumber ]] </span><span class="h6 font-italic">[[ formatDate(curShot.dateFinished, 'ddd MM/DD') ]]</span></span><span v-if="!curShot.qguid">New Shot</span></h4>
    </template>

    <div class="d-block">

      <b-row>      
        <b-col>   
          
          <b-form-group label="Quality"
                        :label-for="'qaQuality'">
            <b-form-select :id="'qaQuality'" :state="validQuality"
                          :options="qualityLevels"       
                          ref="qualitySelect"         
                          v-model="curShot.Quality" size="sm"></b-form-select>
          </b-form-group>                
        </b-col>
      </b-row>

      <b-row>      
        <b-col>   
          <b-form-group label="Notes"
                        :label-for="'qaNotes'">
            <b-form-textarea :id="'qaNotes'" debounce="300"
                            v-model="curShot.Notes" rows="3" max-rows="3">   
            </b-form-textarea>                                                   
          </b-form-group>           
        </b-col>
      </b-row>  

      
      <b-row>      
        <b-col>          
          <b-form-group label="Caliper 1"
                        :label-for="'qaCaliper1'">
            <b-form-input :id="'qaCaliper1'" :state="validCaliper1"
                          v-model="curShot.qaCaliper1" size="sm"></b-form-input>
          </b-form-group>
        </b-col>


        <b-col>     
          <b-form-group label="Caliper 2"
                        :label-for="'qaCaliper2'">
            <b-form-input :id="'qaCaliper2'" :state="validCaliper2"
                          v-model="curShot.qaCaliper2" size="sm"></b-form-input>
          </b-form-group>
        </b-col>
      </b-row>

      <b-row>      
        <b-col>   
          <b-form-group label="Caliper Front"
                        :label-for="'qaCaliperFront'">
            <b-form-input :id="'qaCaliperFront'" :state="validCaliperFront"
                          v-model="curShot.qaCaliperFront" size="sm"></b-form-input>
          </b-form-group>
        </b-col>


        <b-col>                 
          <b-form-group label="Caliper Back"
                        :label-for="'qaCaliperBack'">
            <b-form-input :id="'qaCaliperBack'" :state="validCaliperBack"
                          v-model="curShot.qaCaliperBack" size="sm"></b-form-input>
          </b-form-group>          
        </b-col>
      </b-row>

      <b-row>      
        <b-col>           
          <b-form-group label="Actual Weight"
                        :label-for="'qaActualWeight'">
            <b-form-input :id="'qaActualWeight'" :state="validActualWeight"
                          v-model="curShot.qaActualWeight" size="sm"></b-form-input>
          </b-form-group>
        </b-col>


        <b-col>  
          <b-form-group label="Actual Set Time"
                        :label-for="'qaActualSetTime'">
            <b-form-input :id="'qaActualSetTIme'" :state="validActualSetTime"
                          v-model="curShot.qaActualSetTime" size="sm"></b-form-input>
          </b-form-group>              
        </b-col>
      </b-row>   

      <b-row>
        <b-col>
          <h5>Operator: [[ curShot.PressOperatorName ]]</h5>

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

                {title: '', field:"ActiveTable2", hozAlign:"center", headerSort:false,
                  formatter: function(cell, formatterParams, onRendered){
                    let thisVal = cell.getValue();
                    let thisColor = '#FFFFFF'

                    if (thisVal == '2') {
                      // primary
                      thisColor = "#007bff";
                    }                           

                    cell.getElement().style.backgroundColor = thisColor;

                    return thisVal;
                    },

                  formatterParams: {formatStr: "dd MM/DD"}
                },                            

                {title: '', field:"ActiveTable1", hozAlign:"center", headerSort:false,
                  formatter: function(cell, formatterParams, onRendered){
                    let thisVal = cell.getValue();
                    let thisColor = '#FFFFFF'
                        
                    if (thisVal == '1') {
                      // warning
                      thisColor = "#ffc107";
                    }

                    cell.getElement().style.backgroundColor = thisColor;

                    return thisVal;
                  },

                  formatterParams: {formatStr: "dd MM/DD"}
                },     

                {title: 'WO', field: 'WONumber', responsive: 0, headerSort:false},        
                {title: 'Qty Remain', field: 'QtyRemaining', responsive: 0, headerSort:false},
                {title: 'Qty Needed', field: 'Quantity', responsive: 3, headerSort:false},                
                {title: 'Qty Shot', field: 'CurrentShotCount', responsive: 4, headerSort:false},

                {title: 'Off Press Date', field: 'DateReqOffPress', headerSort:false,
                  formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);},
                  formatterParams: {formatStr: "dd MM/DD"}
                },

                {title: 'Hours Remain', field: 'PressHoursRemain', headerSort:false},

                {title: 'Thick', field: 'DimThickness_Finished', headerSort:false},
                {title: 'Thick OP', field: 'DimThickness_OffPress', headerSort:false},
                {title: 'Width OP', field: 'DimWidth_OffPress', headerSort:false},
                {title: 'Length OP', field: 'DimLength_OffPress', headerSort:false},

                {title: 'Glass', field: 'GlassSpecs', width: '5em', formatter: 'textarea', headerSort:false},  
                {title: 'Shim Layup', field: 'ShimLayup', width: '7em', formatter: 'textarea', headerSort:false},
                {title: 'Glass Layers', field: 'MoldGlassLayers', responsive: 2, headerSort:false},        

                {title: 'Foam', field: 'FoamSystem', responsive: 2, headerSort:false},
                {title: 'Foam Grams', field: 'Weight_Foam', headerSort:false},
                {title: 'Set Time', field: 'SetTimeSeconds', headerSort:false},   
                
                {title: 'Weight OP', field: 'Weight_OffPress', headerSort:false},                
                {title: 'Weight Sanded', field: 'Weight_Sanded', headerSort:false},                

                {title: 'Item', field: 'ItemNumber', responsive: 3, minWidth: 150, headerSort:false},
                {title: 'Customer', field: 'CustomerName', responsive: 3, minWidth: 175, headerSort:false},
                {title: 'SO', field: 'LinkedSONumber', responsive: 3, headerSort:false},                

                {title: 'Commit Date', field: 'CommitDate', responsive: 3, headerSort:false,
                  formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);},
                  formatterParams: {formatStr: "MM/DD"}
                },   

                //{title: 'Finish', field: 'SurfaceFinish', responsive: 4, minWidth: 150},


                {title: 'Notes', field: 'Notes', responsive: 0, minWidth: 175, headerSort:false}
                                                                 
              ],
            },

            tabShotHistOpt: {

              responsiveLayout: 'hide', // enable responsive layouts
              height: '40vh', //with responsiveCollapse we need to specify an absolute height
              layout: 'fitDataFill',
              responsiveLayoutCollapseStartOpen: false,
              //resizableColumns: false,
              columns: [
                                      
                //{title: '', responsive: 0, formatter:"responsiveCollapse", headerSort:false},                                          
                {title: 'WO', field: 'WONumber', responsive: 0, headerSort:true},
                {title: 'Shot', field: 'ShotNumber', responsive: 0, headerSort:true},
                
                {title: 'Time', field: 'DateFinished', responsive: 0, headerSort:true, 
                  formatter: function(cell, formatterParams, onRendered){return moment(cell.getValue()).format(formatterParams.formatStr);},
                  formatterParams: {formatStr: "MM/DD hh:mm dd"}
                },

                {title: 'OperatorName', field: 'PressOperatorName', responsive: 0, headerSort:true},                

                {title: 'Quality', field: 'Quality', responsive: 0, headerSort:false},

                {title: 'Set Time', field: 'qaActualSetTime', responsive: 0, headerSort:false},
                {title: 'Weight', field: 'qaActualWeight', responsive: 0, headerSort:false},
                {title: 'Caliper 1', field: 'qaCaliper1', responsive: 0, headerSort:false},
                {title: 'Caliper 2', field: 'qaCaliper2', responsive: 0, headerSort:false},
                {title: 'Caliper Back ', field: 'qaCaliperBack', responsive: 0, headerSort:false},
                {title: 'Caliper Front', field: 'qaCaliperFront', responsive: 0, headerSort:false},
                
                {title: 'Notes', field: 'Notes', responsive: 0, minWidth: 175, headerSort:false},

                {title: 'qguid', field: 'qguid', visible: false}                
                                                                 
              ],
            },

        qualityLevels: [
          { value: 'A', text: 'A' },
          { value: 'B', text: 'B' },
          { value: 'RW', text: 'RW' }
        ],

        theasParams: {},
        theasLastError: {},
                
        dataRefreshInterval: 15 * 60,  //auto-refresh, in seconds
        enableFetching: true,
        today: moment().toDate(),
        busyCount: 1,
        curCursor: 'progress',

        overlayVisible: false,

        drag: null, 

        // Dynamic data will be fetched asynchronously
        data_WOs: [],
        data_Shots: [],
        data_Workers: [],

        lastFetch_WOs: null,
        lastFetch_Workers: null,

        asyncResource_WOs: 'sched/sched_App.vue',
        asyncCmd_WOs: 'fetchWOsForPress',
        asyncCmd_Workers: 'fetchWorkers',

        pressCodes: ['N', 'NW', 'S', 'W'],

        woListNames: ['N', 'NW', 'S', 'W'],
        curWOListCode: '',
        lockPressSelection: true,

        curWOqguid_Table1: null,
        curWOqguid_Table2: null,   
        curWorkerQGUID: null,     

        curWO: {},
        curWOTable1: {},
        curWOTable2: {},

        curShot: {},
        thisWO_CommitDate: null, // object for datepicker

        keyQuality: 0,
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

      validCaliper1 : function() {
        return this.isNumPress(this.curShot.qaCaliper1);
      },
      validCaliper2 : function() {
        return this.isNumPress(this.curShot.qaCaliper2);
      },
      validCaliperFront : function() {
        return this.isNumPress(this.curShot.qaCaliperFront);
      },
      validCaliperBack : function() {
        return this.isNumPress(this.curShot.qaCaliperBack);
      },
      validActualWeight : function() {
        return this.isNumPress(this.curShot.qaActualWeight);
      },
      validActualSetTime : function() {
        return this.isNumPress(this.curShot.qaActualSetTime, 3600);
      },                        
      validQuality : function() {
        return ((['A', 'B', 'RW'].includes(this.curShot.Quality)));
      }

    },

    methods: {

      fullscreen: function () {
        if (screenfull.isEnabled) {
          screenfull.request();
        }
      }, 

      onShowShotHistory: function() {
        let thatVue = this;
      },

      onHideShotHistory: function(qguid, evt) {
        let thatVue = this; 
      },

      onShowWOQuality: function() {
        let thatVue = this;
      },

      onHideWOQuality: function(qguid, evt) {
        let thatVue = this;

        if (evt.trigger === 'ok') {          
          thatVue.saveShot();
        }          

        //don't clear shot here:  saveShot will clear it on receipt of a response
        //thatVue.curShot = {};             
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

      onHistoryRowClick: function(e, row) {
        let thatVue = this;

        thatVue.curShot = thatVue.data_Shots.find((el) => el.qguid === row.getData().qguid);
        
        //for testing only
        //let thisIndex = thatVue.data_Shots.findIndex((el) => el.qguid === thatVue.curShot.qguid)
        //if (thisIndex >= 0) {
        //  thatVue.data_Shots[thisIndex] = thatVue.curShot;
        //}
                            
        //thatVue.$bvModal.hide('ShotHistoryModal');           
        thatVue.$bvModal.show('WOQualityModal'); 
      },

      switchWOList: function() {
        let thatVue = this;    
        
        thatVue.data_WOs = [];
        thatVue.lastFetch_WOs = null;
        thatVue.fetchWOs();
      },

      fetchWorkers: function (workerType) {
        // save reference to Vue object
        let thatVue = this;

        thatVue.incBusy();        

        if (!workerType) {
          workerType = '';
        }

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
                thatVue.data_Workers.forEach(wrk => {
                  wrk.value = wrk.qguid;
                  wrk.text = wrk.Worker;
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
          data: {listName: thatVue.curWOListCode}, //note: passes to @FormParams
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

              if (rd["General"]) {
                thisObj = JSON.parse(rd["General"]);
                if (thisObj.PressCode) {
                  thatVue.lockPressSelection = true;
                  thatVue.curWOListCode = thisObj.PressCode;
                }
                else {
                  thatVue.lockPressSelection = false;
                }
              }

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
                  //make sure select for Press Code matches the actual work order data.
                  //(this allows the default to be controlled in SQL)
                  thatVue.curWOListCode = thatVue.data_WOs[0].PlannedPress;
                }


                //apply server-side WO table assignments
                if (thatVue && thatVue.data_WOs && thatVue.data_WOs.length > 0) {
                    thatVue.curWOTable1 = thatVue.data_WOs.find((el) => el.ActiveTable1 === '1');
                    thatVue.curWOqguid_Table1 = null;
                    if (thatVue.curWOTable1) {
                      thatVue.curWOqguid_Table1 = thatVue.curWOTable1.qguid                       
                    }
                          
                    if (thatVue.data_WOs.length > 1) {
                      thatVue.curWOTable2 = thatVue.data_WOs.find((el) => el.ActiveTable2 === '2');
                      thatVue.curWOqguid_Table2 = null;                      
                      if (thatVue.curWOTable2) {
                        thatVue.curWOqguid_Table2 = thatVue.curWOTable2.qguid;   
                      }                                                           
                    }
                }             
                

              }


              // Shots
              if (1==1 && rd["Shots"]) {
                thisObj = JSON.parse(rd["Shots"])[0];
                thisData = thisObj["JSONData"];
                thisFetchDate = thisObj["FetchDate"];

                if (config.reFetch) {
                  //thatVue.data_Shots.length = 0; //clear out WO      
                  thatVue.data_Shots = [];
                }          

                if (thisData) {
                  thatVue.data_Shots = thatVue.$th.merge(
                          // string (optional): key field name with unique values to merge on
                          "qguid",
                          // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                          //'someIDValue'
                          thatVue.data_Shots,
                          thisData
                  );

                  // remove any shots that don't have a qguid (i.e. recently-added temporary shots that should now have been received with a qguid
                  thatVue.data_Shots = thatVue.data_Shots.filter((qguid) => true ? qguid : false)

                }
                thatVue.data_Shots = thatVue.$th.sortArray(
                        thatVue.data_Shots,
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
            thatVue.fetchWorkers();
            // can add additional fetches here
          }
        }

        thatVue.decBusy();        
      },
    

      changeActiveWO: function (tableCode, qguid) {
        let thatVue = this; 

        let wo = thatVue.data_WOs.find((el) => el.qguid === qguid);

        if (tableCode == 'Table1') {
          if (thatVue.curWOTable1 != wo) {
            thatVue.curWOTable1 = wo;

            thatVue.saveSelectWO(qguid, tableCode);
          }
        }

        else if (tableCode == 'Table2') {
          if (thatVue.curWOTable2 != wo) {          
            thatVue.curWOTable2 = wo;    

            thatVue.saveSelectWO(qguid, tableCode);
          }          
        }

      },

      showHistory: function() {        
        let thatVue = this;

        thatVue.$bvModal.show('ShotHistoryModal');         

        setTimeout(function(){
        //Vue.nextTick(function () {     
            //need to refdraw the table after the modal is shown.  nextTick does not work, but setTimeout does work.     
            thatVue.$refs.tabuShotHistory.tabulatorInstance.redraw(true);
        //});            
        }, 100);        
      },

      completeShot: function(tableCode) {
          let thatVue = this;

          if (!thatVue.curWorkerQGUID) {
            //TechnicalMessage|FriendlyMessage|ShowTech?|Title
            thatVue.$th.raiseError('|Please select the operator that is working on this press.|1|No operator selected!');
          }
          else {
            let thisWO;

            thatVue.curShot = {};

            //a new shot:  assign values
            thatVue.curShot.qguidPressOperator = thatVue.curWorkerQGUID;
            thatVue.curShot.PressOperatorName = thatVue.curWorkerName();

            if (!thatVue.curShot.qguidWO) {
              
              if (tableCode == 'Table1') {
                thisWO = thatVue.curWOTable1
              }
              else if (tableCode == 'Table2') {
                thisWO = thatVue.curWOTable2
              }          

              if (!thisWO.qguid) {
                //TechnicalMessage|FriendlyMessage|ShowTech?|Title
                thatVue.$th.raiseError('|No Work Order selected.  Cannot add a new shot.|1|No work order selected!');
              }
              else {
                thatVue.curShot.qguidWO = thisWO.qguid;
                thatVue.curShot.WONumber = thisWO.WONumber;
              }
            }              
       

            thatVue.$bvModal.show('WOQualityModal');            
          }
      },

      saveSelectWO: function (qguid, tableCode, event) {
          // save reference to Vue object that can be used in async callbacks
          let thatVue = this;

          if (!qguid) {
            qguid = '';
          }

          thatVue.data_WOs.forEach((el, index, arr) => {
            if (tableCode == 'Table1') {
              arr[index].ActiveTable1 = (el.qguid == qguid) ? '1': '';
            }
            else if (tableCode == 'Table2') {
              arr[index].ActiveTable2 = (el.qguid == qguid) ? '2' : '';                 
            }         
          });

          thatVue.$th.sendAsync({
            url: "/async/" + thatVue.asyncResource_WOs,
            asyncCmd: 'selectWO',              
            data: {qguid: qguid, tableCode: tableCode}, //note: passes to @FormParams

            onResponse: function (rd, response) {
              let noop;
            }
          });

      },


      saveShot: function() {
          // save reference to Vue object that can be used in async callbacks
          let thatVue = this;

          // make sure curShot has been saved to data_Shots

          if (thatVue.curShot.qguid) {
            // updating existing shot

            let thisIndex = thatVue.data_Shots.findIndex((el) => el.qguid === thatVue.curShot.qguid);
            if (thisIndex >= 0) {
              thatVue.data_Shots[thisIndex] = thatVue.curShot;
            }

          }
          else {
            // new shot
            thatVue.data_Shots.unshift(thatVue.curShot);
          }


          thatVue.$th.sendAsync({
            url: "/async/" + thatVue.asyncResource_WOs,
            asyncCmd: 'completeShot',              
            data: {Shot: thatVue.curShot}, //note: passes to @FormParams

            onResponse: function (rd, response) {
                // rd contains the response data split into an object (of name/value pairs)
                // (might have been returned as either a string of URL-encoded name/value
                // pairs, or as a JSON strong)

                // response contains the complete response object, in which .data contains
                // the raw data that was received.              

                /*
                let thisIndex = thatVue.data_WOs.findIndex((el) => el.qguid === qguid)
                if (thisIndex >= 0) {
                  thatVue.curShot = thatVue.data_Shots[thisIndex];
                }
                */

              let shotResp= {};         

              if (!thatVue.$th.haveError(true)) {

                //  ShotResponse
                if (rd["ShotResponse"]) {
                  shotResp = JSON.parse(rd["ShotResponse"]);
                }

                if (shotResp) {

                  for (const [key, value] of Object.entries(shotResp)) {
                    thatVue.curShot[key] = value;
                  }                                

                  let thisIndexWO = thatVue.data_WOs.findIndex((el) => el.qguid === shotResp.qguidWO);
                  if (thisIndexWO >= 0) {
                    thatVue.data_WOs[thisIndexWO].CurrentShotCount = shotResp.CurrentShotCount;
                  }

                }     

              }

              thatVue.curShot = {};     

              let tab = thatVue.$refs.tabuShotHistory;
              if (tab) {
                tab.tabulatorInstance.redraw(true);     
              }

            }
          });

      },

      formatDate: function (thisDate, thisFormatStr) {
        //if (typeof thisDate === 'string' || thisDate instanceof String) {
        //    thisDate = thisDate.replace('T', ' ');
        //}
        let result = moment(thisDate).format(thisFormatStr);
        return result;
      },

      curWorkerName: function() {
        let thisWorker = this.data_Workers.find((el) => el.qguid == this.curWorkerQGUID);

        let thisName = null;

        if (thisWorker) {
          thisName = thisWorker.Worker;
        }
        
        return thisName
      },

      isQARequired : function() {
        //let isNewShot = (!Boolean(this.curShot.qugid));

        //if (!isNewShot) {
        //  return false
        //}

        //else {

        //  let isRequired = false;

          // Required on first, last and each 10th
        //  return (thisSeq == 1 || thisSeq == this.curWO.Quantity || (curWO.ShotSeq % 10) == 0)

       // }
       return false;
      },

      isNumPress : function(thisVal, maxValue) {
        let thisValLen = 0;

        if (typeof thisVal === 'string') {
          thisValLen = thisVal.length;          
        }

        if (!maxValue) {
          maxValue = 200;
        }
     
        let isValid = (this.isQARequired() === false && thisValLen === 0) || (Number(thisVal) >= 0 && Number(thisVal) <= maxValue);

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

</style>
