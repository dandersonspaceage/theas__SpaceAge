<template>
  <div v-bind:style="{ cursor: curCursor }">

    <b-container id="NewPage1_Appvue">

      <b-row no-gutters fluid>

        <b-col>

            <b-form-group label="Press"
                          :label-for="'ListName'">
              <b-form-select :id="'listName'"
                            v-model="curWOList" :options="woListNames" @change="switchWOList()"
                            size="sm"></b-form-select>
            </b-form-group>

            <h3>[[ curWOList ]]</h3>
              <div class="fastscroll" style="height:75vh;">

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
                                        v-model="wo.PlannedPress" :options="pressCodes" @change="onChangePlan(wo.qguid, $event)"
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
                                                  :min="today" @input="onChangePlan(wo.qguid, $event)"
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
                                          @change="onChangePlan()"
                                          v-model="wo.Notes" rows="3" max-rows="3">
                          </b-form-textarea>
                        </b-form-group>
                      </b-col>
                    </b-row>

                  </b-collapse>

                </b-card>

              </div>

        </b-col>

      </b-row>

    <b-container>

    <b-modal id="thModal" hide-footer>
      <template #modal-title>
        Using <code>$bvModal</code> Methods
      </template>
      <div class="d-block text-center">
        <h3>Hello From This Modal!</h3>
      </div>
      <b-button class="mt-3" block @click="$bvModal.hide('thModal')">Close Me</b-button>
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
        dataRefreshInterval: 15,
        enableFetching: true,
        today: moment().toDate(),

        overlayVisible: false,

        showModal: false,

        // Dynamic data will be fetched asynchronously
        data_WOs: [],

        lastFetch_WOs: null,
        curCursor: 'default',

        asyncResource_WOs: 'saltd/sched_App.vue',
        asyncCmd_WOs: 'fetchWOs',

        pressCodes: ['N', 'NW', 'S', 'W'],

        woListNames: ['Unscheduled', 'N', 'NW', 'S', 'W'],
        curWOList: 'Unscheduled',

        data_ThisWO: {},
        thisWO_CommitDate: null, // object for datepicker
      };
    },

    // method executed when the Vue object is created
    created: function () {
      document.body.style.cursor = 'progress';      

      // perform the initial fetch of data
      this.fetchData(true);        
    },

    methods: {
      fullscreen: function () {
        if (screenfull.isEnabled) {
          screenfull.request();
        }
      },

      testMe: function() {
        let thatVue = this;
        thatVue.$th.showModal('ABCDEFG');
        //thatVue.$bvModal.show('thModal');

        //thatVue.$th.showModal('Here is a fake error')
      },

      switchWOList: function() {
        let thatVue = this;        

        document.body.style.cursor = 'progress';         
        
        thatVue.data_WOs = [];
        thatVue.lastFetch_WOs = null;
        thatVue.fetchWOs();
       
      },

      toggleWODetail: function(qguid, event) {
        // save reference to Vue object
        let thatVue = this;
        
        // find the corresponding WO  https://stackoverflow.com/questions/12462318/find-a-value-in-an-array-of-objects-in-javascript
        thatVue.data_ThisWO = thatVue.data_WOs.find(o => o.qguid === qguid);
        //Note:  data_thisWO gets set to the most recently-expanded WO, but that is not
        //a guarantee that data_thisWO is the only one that may be edited by the user (as
        //multiple WO's could be expanded)
      },     

      fetchWOs: function () {
        // save reference to Vue object
        let thatVue = this;

        thatVue.curCursor = 'progress';        

        thatVue.$th.sendAsync({
          url: "/async/" + thatVue.asyncResource_WOs,
          asyncCmd: thatVue.asyncCmd_WOs,
          lastFetchDate: thatVue.lastFetch_WOs,
          data: {listName: thatVue.curWOList}, //note: passes to @FormParams

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

              if (thatVue && thatVue.data_thisWO && thatVue.data_thisWO.qguid) {
                thatVue.data_ThisWO = thatVue.data_WOs.find(o => o.qguid === thatVue.data_thisWO.qguid);                             
              }

              thatVue.curCursor = 'default';
              document.body.style.cursor = 'default';               

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

        thatVue.curCursor = 'default';
        document.body.style.cursor = 'default';           

      },
    

      onChangePlan: function (qguid, event) {
          let thatVue = this;                    
          thatVue.saveWO(qguid, event);          
      },

      saveWO: function (qguid, event) {
          // save reference to Vue object that can be used in async callbacks
          var thatVue = this;

          thatVue.$th.sendAsync({
              url: "/async/" + thatVue.asyncResource_WOs,
              asyncCmd: 'updateWO',
              data: {WO: qguid}, //note: passes to @FormParams

              onResponse: function (rd, response) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.              

                  let thisIndex = thatVue.data_WOs.findIndex(o => o.qguid === qguid)
                  if (thisIndex >= 0) {
                    thatVue.data_ThisWO = thatVue.data_WOs[thisIndex];

                    if
                      (
                        (thatVue.curWOList == 'Unscheduled' && thatVue.data_ThisWO.CommitDate && thatVue.data_ThisWO.PlannedPress) ||
                        (thatVue.curWOList != 'Unscheduled' && thatVue.curWOList != thatVue.data_ThisWO.PlannedPress)
                      ){
                        thatVue.$delete(thatVue.data_WOs, thisIndex);
                        thatVue.data_ThisWO = {};                    
                      }
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
