<template>
  <div>

    <b-container id="NewPage1_Appvue">

      <b-row no-gutters fluid>

        <b-col>
          <b-row>

            <b-tabs ref="tabs" v-model="currentTabNumber" @click="flushDirt" active>
              <b-tab title="To Schedule">
                
                <div class="fastscroll" style="height:75vh;" v-swipeleft="prevtab" v-swiperight="nexttab">

                  <b-card v-for="wo in data_WOs" :key="wo.qguid">

                    <b-row>
                      <b-col>
                        <h4>WO: [[ wo.WONumber ]]</h4>
                      </b-col>
                      <b-col>
                        <h4>SO: [[ wo.LinkedSONumber ]]</h4>
                      </b-col>
                    </b-row>

                    <b-row>
                      <b-col>
                        <h4>[[ wo.CustomerName ]]</h4>
                      </b-col>
                    </b-row>

                    <b-row>
                      <b-col>
                        <h5>Item: [[ wo.ItemNumber ]]</h5>
                      </b-col>
                    </b-row>

                    <b-row>
                      <b-col>
                        <h5>Qty: [[ wo.Quantity ]]<span class='bg-warning' v-if="wo.CurrentShotCount">Qty Remaining:
                          [[ wo.QtyRemaining ]]</span></h5>
                      </b-col>
                    </b-row>

                    <b-btn v-b-toggle="'collapse' + wo.qguid" @click="toggleWODetail(wo.qguid, $event)" >
                      <span class="when-opened">
                        <i class="fa fa-chevron-down" aria-hidden="true"></i>
                      </span>
                      <span class="when-closed">       
                        <i class="fa fa-chevron-up" aria-hidden="true"></i>
                          [[ formatDate(wo.CommitDate, 'ddd MM/DD') ]]   
                        </span>
                    </b-btn>

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
                                          v-model="wo.PlannedPress" :options="pressCodes" @change="onChangePlan()"
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
                                                    v-model="wo.CommitDate"
                                                    :min="today" @change="onChangePlan()"
                                                    size="sm" :dark="true" locale="en">
                                  </b-form-datepicker>

                                </b-td>
                              </b-tr>

                              <b-tr>
                                <b-td>
                                  Press Date
                                </b-td>
                                <b-td>
                                  [[ formatDate(wo.SchedPressDate, 'ddd MM/DD') ]]
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
                            <b-form-textarea :id="'notes' + [[wo.qguid]]" debounce="1000"
                                            v-model="wo.Notes" rows="3" max-rows="3">
                            </b-form-textarea>
                          </b-form-group>
                        </b-col>
                      </b-row>

                    </b-collapse>

                  </b-card>

                </div>
              </b-tab>

              <b-tab title="North Press">
                <div class="fastscroll" style="height:75vh;" v-swipeleft="prevtab" v-swiperight="nexttab">

                  <h3>North Press</h3>

                    <b-card v-for="wo in data_PressN" :key="wo.qguid">
                      <b-row>
                        <b-col>
                          <draggable v-model="data_PressN" group="woN" @change="log">
                            <h4>WO: [[ wo.WONumber ]]</h4>                      
                          </draggable>
                        </b-col>
                        <b-col>
                          <h4>SO: [[ wo.LinkedSONumber ]]</h4>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h4>[[ wo.CustomerName ]]</h4>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Item: [[ wo.ItemNumber ]]</h5>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Qty: [[ wo.Quantity ]]<span class='bg-warning'
                                                          v-if="wo.CurrentShotCount">Qty Remaining:
                            [[ wo.QtyRemaining ]]</span></h5>
                        </b-col>
                      </b-row>
                    <b-btn v-b-toggle="'collapse' + wo.qguid">
                      <span class="when-opened">
                        <i class="fa fa-chevron-down" aria-hidden="true"></i>
                      </span>
                      <span class="when-closed">       
                        <i class="fa fa-chevron-up" aria-hidden="true"></i>
                          [[ formatDate(wo.CommitDate, 'ddd MM/DD') ]]   
                        </span>
                    </b-btn>

                    <b-collapse :id="'collapse' + wo.qguid">
                      <b-row>
                        <b-col>
                          <p>[[ wo.ItemDescription ]]</p>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5> Total Weight:  [[ wo.TotalWeight ]]</h5>
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
                                          v-model="wo.PlannedPress" :options="pressCodes"
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
                                                    :value-as-date="true"
                                                    :date-format-options="{year:undefined, month: '2-digit', day: '2-digit', weekday: 'short' }"
                                                    v-model="wo.CommitDate" :min="today"
                                                    size="sm" :dark="true" locale="en">
                                  </b-form-datepicker>

                                </b-td>
                              </b-tr>

                              <b-tr>
                                <b-td>
                                  Press Date
                                </b-td>
                                <b-td>
                                  [[ formatDate(wo.SchedPressDate, 'ddd MM/DD') ]]
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
                            <b-form-textarea :id="'notes' + [[wo.qguid]]" debounce="1000"
                                            v-model="wo.Notes" rows="3" max-rows="3">
                            </b-form-textarea>
                          </b-form-group>
                        </b-col>
                      </b-row>

                    </b-collapse>


                    </b-card>
                  
                </div>
              </b-tab>

              <b-tab title="South Press">
                <div class="fastscroll" style="height:75vh;" v-swipeleft="prevtab" v-swiperight="nexttab">

                  <h3>South Press</h3>

                    <b-card v-for="wo in data_PressS" :key="wo.qguid">
                      <b-row>
                        <b-col>
                          <draggable v-model="data_PressS" group="woS" @change="log">
                            <h4>WO: [[ wo.WONumber ]]</h4>                      
                          </draggable>
                        </b-col>
                        <b-col>
                          <h4>SO: [[ wo.LinkedSONumber ]]</h4>
                        </b-col>
                      </b-row>


                      <b-row>
                        <b-col>
                          <h4>[[ wo.CustomerName ]]</h4>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Item: [[ wo.ItemNumber ]]</h5>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Qty: [[ wo.Quantity ]]<span class='bg-warning'
                                                          v-if="wo.CurrentShotCount">Qty Remaining:
                            [[ wo.QtyRemaining ]]</span></h5>
                        </b-col>
                      </b-row>

                    </b-card>
                  <!--/draggable -->

                </div>
              </b-tab>

              <b-tab title="West Press">
                <div class="fastscroll" style="height:75vh;" v-swipeleft="prevtab" v-swiperight="nexttab">

                  <h3>West Press</h3>

                    <b-card v-for="wo in data_PressW" :key="wo.qguid">
                      <b-row>
                        <b-col>
                          <draggable v-model="data_PressW" group="woW" @change="log">
                            <h4>WO: [[ wo.WONumber ]]</h4>                      
                          </draggable>
                        </b-col>
                        <b-col>
                          <h4>SO: [[ wo.LinkedSONumber ]]</h4>
                        </b-col>
                      </b-row>


                      <b-row>
                        <b-col>
                          <h4>[[ wo.CustomerName ]]</h4>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Item: [[ wo.ItemNumber ]]</h5>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Qty: [[ wo.Quantity ]]<span class='bg-warning'
                                                          v-if="wo.CurrentShotCount">Qty Remaining:
                            [[ wo.QtyRemaining ]]</span></h5>
                        </b-col>
                      </b-row>

                    </b-card>
                  <!-- /draggable -->

                </div>
              </b-tab>          
              
              <b-tab title="Northwest Press">
                <div class="fastscroll" style="height:75vh;" v-swipeleft="prevtab" v-swiperight="nexttab">

                  <h3>Northwest Press</h3>

                    <b-card v-for="wo in data_PressNW" :key="wo.qguid">
                      <b-row>
                        <b-col>
                          <draggable v-model="data_PressNW" group="woNW" @change="log">
                            <h4>WO: [[ wo.WONumber ]]</h4>                      
                          </draggable>
                        </b-col>
                        <b-col>
                          <h4>SO: [[ wo.LinkedSONumber ]]</h4>
                        </b-col>
                      </b-row>


                      <b-row>
                        <b-col>
                          <h4>[[ wo.CustomerName ]]</h4>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Item: [[ wo.ItemNumber ]]</h5>
                        </b-col>
                      </b-row>

                      <b-row>
                        <b-col>
                          <h5>Qty: [[ wo.Quantity ]]<span class='bg-warning'
                                                          v-if="wo.CurrentShotCount">Qty Remaining:
                            [[ wo.QtyRemaining ]]</span></h5>
                        </b-col>
                      </b-row>

                    </b-card>
                  <!-- /draggable -->

                </div>
              </b-tab>                 
            </b-tabs>

        </b-col>

      </b-row>

    <b-container>
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
        dataRefreshInterval: 15,
        enableFetching: true,
        today: moment().toDate(),

        overlayVisible: false,

        currentTabNumber: 0,

        // Dynamic data will be fetched asynchronously
        data_WOs: [],
        data_PressN: [],
        data_PressS: [],
        data_PressW: [],
        data_PressNW: [],
        lastFetch_WOs: null,
        lastFetch_PressN: null,
        asyncResource_WOs: "saltd/sched_App.vue",
        asyncCmd_WOs: "fetchWOs",

        pressCodes: ["N", "NW", "S", "W"],

        data_ThisWO: {},
        thisWO_CommitDate: null, // object for datepicker
      };
    },

    // method executed when the Vue object is created
    created: function () {
      // perform the initial fetch of data
      this.fetchData(true);
    },

    methods: {
      fullscreen: function () {
        if (screenfull.isEnabled) {
          screenfull.request();
        }
      },

      nexttab: function (e) {
          let thatVue = this;

          thatVue.flushDirt();

          thatVue.currentTabNumber--;
          if (thatVue.currentTabNumber < 0) {
              thatVue.currentTabNumber = thatVue.tabCount - 1
          }
      },

      prevtab: function (e) {
          let thatVue = this;

          thatVue.flushDirt();

          thatVue.currentTabNumber++;
          if (thatVue.currentTabNumber > thatVue.tabCount - 1) {
              thatVue.currentTabNumber = 0
          }
      },      

      toggleWODetail: function(qguid, event) {
        // save reference to Vue object
        let thatVue = this;
        
        // find the corresponding WO  https://stackoverflow.com/questions/12462318/find-a-value-in-an-array-of-objects-in-javascript
        thatVue.data_ThisWO = thatVue.data_WOs.find(o => o.qguid === qguid);           
      },

      flushDirt: function () {
          let thatVue = this;
/*
          if (thatVue.curDirtyComponent && thatVue.curDirtyComponent != {} && thatVue.curDirtyComponent.qguid) {
              thatVue.onActivityChanged(
                  thatVue.curDirtyComponent.isNote === true ? thatVue.curARNotes[thatVue.curDirtyComponent.mcode] : thatVue.curAR[thatVue.curDirtyComponent.mcode],
                  thatVue.curDirtyComponent.qguid,
                  thatVue.curDirtyComponent.isNote
              );
          }
*/
      },      

      fetchWOs: function () {
        // save reference to Vue object
        let thatVue = this;

        thatVue.$th.sendAsync({
          url: "/async/" + thatVue.asyncResource_WOs,
          asyncCmd: thatVue.asyncCmd_WOs,
          lastFetchDate: thatVue.lastFetch_WOs,

          onResponse: function (rd, response) {
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

            //  WOs
            if (rd["WOs"]) {
              thisObj = JSON.parse(rd["WOs"])[0];
              thisData = thisObj["JSONData"];
              thisFetchDate = thisObj["FetchDate"];

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

              /* Copy the current date over to the datepicker's value object */
              if (thatVue && thatVue.data_thisWO && thatVue.data_thisWO.qguid) {
                thatVue.data_ThisWO = thatVue.data_WOs.find(o => o.qguid === thatVue.data_thisWO.qguid);                
                thatVue.thisWO_CommitDate = thatVue.data_ThisWO.CommitDate;                
              }
              else {
                thatVue.thisWO_CommitDate = null;
              }

 
          
            }

            thisObj = {};
            thisData = [];
            thisFetchDate = null;

            //  PressN
            if (rd["PressN"]) {
              thisObj = JSON.parse(rd["PressN"])[0];
              thisData = thisObj["JSONData"];
              thisFetchDate = thisObj["FetchDate"];

              if (thisData) {
                thatVue.data_PressN = thatVue.$th.merge(
                        // string (optional): key field name with unique values to merge on
                        "qguid",
                        // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                        //'someIDValue'
                        thatVue.data_PressN,
                        thisData
                );
              }
              thatVue.data_PressN = thatVue.$th.sortArray(
                      thatVue.data_PressN,
                      "Seq",
                      false //false=ascending, true=descending
              );

              if (thatVue.lastFetch_WOs) {
                thatVue.lastFetch_PressN = thisFetchDate;
              } else {
                thatVue.lastFetch_PressN = "1/1/1900";
              }
            }

            thisObj = {};
            thisData = [];
            thisFetchDate = null;

            //  PressS
            if (rd["PressS"]) {
              thisObj = JSON.parse(rd["PressS"])[0];
              thisData = thisObj["JSONData"];
              thisFetchDate = thisObj["FetchDate"];

              if (thisData) {
                thatVue.data_PressS = thatVue.$th.merge(
                        // string (optional): key field name with unique values to merge on
                        "qguid",
                        // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                        //'someIDValue'
                        thatVue.data_PressS,
                        thisData
                );
              }
              thatVue.data_WOs = thatVue.$th.sortArray(
                      thatVue.data_PressS,
                      "Seq",
                      false //false=ascending, true=descending
              );

              if (thatVue.lastFetch_PressS) {
                thatVue.lastFetch_PressS = thisFetchDate;
              } else {
                thatVue.lastFetch_PressS = "1/1/1900";
              }
            }

            thisObj = {};
            thisData = [];
            thisFetchDate = null;

            //  PressNW
            if (rd["PressNW"]) {
              thisObj = JSON.parse(rd["PressNW"])[0];
              thisData = thisObj["JSONData"];
              thisFetchDate = thisObj["FetchDate"];

              if (thisData) {
                thatVue.data_PressNW = thatVue.$th.merge(
                        // string (optional): key field name with unique values to merge on
                        "qguid",
                        // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                        //'someIDValue'
                        thatVue.data_PressNW,
                        thisData
                );
              }
              thatVue.data_WOs = thatVue.$th.sortArray(
                      thatVue.data_PressNW,
                      "Seq",
                      false //false=ascending, true=descending
              );

              if (thatVue.lastFetch_PressNW) {
                thatVue.lastFetch_PressS = thisFetchDate;
              } else {
                thatVue.lastFetch_PressS = "1/1/1900";
              }
            }

            thisObj = {};
            thisData = [];
            thisFetchDate = null;

            //  PressW
            if (rd["PressW"]) {
              thisObj = JSON.parse(rd["PressW"])[0];
              thisData = thisObj["JSONData"];
              thisFetchDate = thisObj["FetchDate"];

              if (thisData) {
                thatVue.data_PressW = thatVue.$th.merge(
                        // string (optional): key field name with unique values to merge on
                        "qguid",
                        // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                        //'someIDValue'
                        thatVue.data_PressW,
                        thisData
                );
              }
              thatVue.data_WOs = thatVue.$th.sortArray(
                      thatVue.data_PressW,
                      "Seq",
                      false //false=ascending, true=descending
              );

              if (thatVue.lastFetch_PressW) {
                thatVue.lastFetch_PressS = thisFetchDate;
              } else {
                thatVue.lastFetch_PressS = "1/1/1900";
              }
            }
          },
        });
      },

      fetchData: function (forceOnError) {
        let thatVue = this;

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
      },
    

      onChangePlan: function () {
          let thatVue = this;
          //thatVue.data_ThisWO.CommitDate = thatVue.thisWO_CommitDate.toISOString();
          thatVue.saveWO();          
      },

      saveWO: function () {
          // save reference to Vue object that can be used in async callbacks
          let thatVue = this;


          thatVue.$th.sendAsync({
              url: "/async/" + thatVue.asyncResource_WOs,
              asyncCmd: 'updateWO',
              data: {WO: thatVue.data_ThisWO}, //note: passes to @FormParams

              onResponse: function (rd, response) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.

                  let thatVue = this;                  



                  //if (response.data && response.data.length > 0 && response.data[0].JSONData) {
                  //    thatVue.dataPatients = thatVue.th.merge(thatVue.dataPatients, response.data[0].JSONData);
                  //    thatVue.fetchedPatients = thisObj['FetchDate'];

                      // patients were updated, so rebuild name-value list
                  //    thatVue.nvPatients = thatVue.th.arrayObjToNV(thatVue.dataPatients, 'qguid', 'PatientName');
                  //}
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
      log: function (evt) {
        window.console.log(evt);
      },
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
</style>
