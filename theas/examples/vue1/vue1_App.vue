<template>
  <div :style="{ cursor: curCursor}">

    <b-container id="Vue1_Appvue">

      <b-row no-gutters fluid>

        <b-col>     
            <h6><span v-if="isBusy()">Loading</span><span v-if="!isBusy()">[[ data_RS1.length ]]</span><span>orders</span></h6>
              <div class="fastscroll" style="height:75vh;">

                  <b-card v-for="rec in data_RS1" :key="rec.qguid">

                    <b-row> 
                        
                        <h6>Description: [[ rec.Description ]]</h6>
                    </b-row>

                    <b-row>
                      <b-col>
                        <h6>[[ rec.qguid ]]</h6>
                      </b-col>
                    </b-row>

                    <b-row>
                      <b-col>
                        <b-btn v-b-toggle="'collapse' + rec.qguid" @click="toggleRecDetail(rec.qguid, $event)">
                          <span class="when-opened">
                            <i class="fa fa-chevron-down" aria-hidden="true"></i>
                          </span>
                          <span class="when-closed">       
                            <i class="fa fa-chevron-up" aria-hidden="true"></i>
                              [[ formatDate(rec.RequestDate, 'ddd MM/DD') ]]   
                            </span>
                        </b-btn>
                      </b-col>

                      <b-col>
                        <span class='bg-warning' v-if="!rec.CommitDate">No Commit Date</span>
                      </b-col>
                    </b-row>
                

                    <b-collapse :id="'collapse' + rec.qguid">
                      <b-row>
                        <b-col>
                          <p>[[ rec.qguid]]</p>
                        </b-col>
                      </b-row>

                    </b-collapse>

                  </b-card>               

              </div>

        </b-col>

      </b-row>

    <b-container>

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

</template>

<script>
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

        drag: null,
        disableDraggable: false,

        // Dynamic data will be fetched asynchronously
        data_RS1: [],

        lastFetch_RS1: null,

        asyncResource: 'theas/examples/vue1/vue1_App.vue',
        asyncCmd: 'fetchVue1',

        curRec: {}
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
      // perform the initial fetch of data
      this.decBusy();
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

      setDirty: function(qguid, debounceMS, reFetch, event) {
        // Enqueues a speific record (via qguid) for saving.
        // Needed for textarea autosave:  lets us debounce saving, while still triggering save on KeyUp
        let thatVue = this;

        // temporarily disable draggable
        // fetchRec and/or saveRec will incBusy / decBusy...which will properly set disableDraggable as needed
        thatVue.disableDraggable = true;

        if (!debounceMS && debounceMS !== 0) {
          //default to 3 seconds
          debounceMS = 3000;
        }

        let thisDirty = thatVue.dirtyQGUIDs.find((el) => el === qguid);
        if (!thisDirty) {
          thatVue.dirtyQGUIDs.push(qguid);
          thatVue.dirtyTimers.push({timer: setTimeout(thatVue.saveRec, debounceMS, qguid, reFetch, event), qguid: qguid});
          //note:  timeout of 3000ms must be longer than debounce of 500ms in textarea       
        }    
      },

      toggleRecDetail: function(qguid, event) {
        // save reference to Vue object
        let thatVue = this;
        
        // find the corresponding record  https://stackoverflow.com/questions/12462318/find-a-value-in-an-array-of-objects-in-javascript
        thatVue.data_ThisRec = thatVue.data_RS1.find((el) => el.qguid === qguid);
        //Note:  data_ThisRec gets set to the most recently-expanded record, but that is not
        //a guarantee that data_ThisRec is the only one that may be edited by the user (as
        //multiple records could be expanded)
      },     

      fetchRS1: function (qguid, reFetch) {
        // save reference to Vue object
        let thatVue = this;

        thatVue.incBusy();        

        thatVue.$th.sendAsync({
          url: "/async/" + thatVue.asyncResource,
          asyncCmd: thatVue.asyncCmd,
          lastFetchDate: thatVue.lastFetch_RS1,
          data: {}, //note: passes to @FormParams
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

              //  RS1
              if (rd["RS1"]) {
                thisObj = JSON.parse(rd["RS1"])[0];
                thisData = thisObj["JSONData"];
                thisFetchDate = thisObj["FetchDate"];

                if (config.reFetch) {
                  thatVue.data_RS1.length = 0; //clear out RS1      
                }          

                if (thisData) {
                  thatVue.data_RS1 = thatVue.$th.merge(
                          // string (optional): key field name with unique values to merge on
                          "qguid",
                          // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                          //'someIDValue'
                          thatVue.data_RS1,
                          thisData
                  );
                }
                thatVue.data_RS1 = thatVue.$th.sortArray(
                        thatVue.data_RS1,
                        "Seq",
                        false //false=ascending, true=descending
                );

                if (thatVue.lastFetch_RS1) {
                  thatVue.lastFetch_RS1 = thisFetchDate;
                } else {
                  thatVue.lastFetch_RS1 = "1/1/1900";
                }

                if (thatVue && thatVue.data_ThisRec && thatVue.data_thisrec.qguid) {
                  thatVue.data_ThisRec = thatVue.data_RS1.find((el) => el.qguid === thatVue.data_thisrec.qguid);                             
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
            thatVue.fetchRS1();
            // can add additional fetches here
          }
        }

        thatVue.decBusy();        
      },
    

      onChangePlan: function (qguid, event) {
          let thatVue = this;  
          thatVue.setDirty(qguid);                         
      },

      saveRec: function (qguid, reFetch, event) {
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

            let thisRec = thatVue.data_RS1.find((el) => el.qguid === qguid)

            if (thisRec) {
              thatVue.$forceUpdate();
            }

            thatVue.incBusy();     

            thatVue.$th.sendAsync({
              url: "/async/" + thatVue.asyncResource,
              asyncCmd: 'updateRec',
              data: {Rec: curRec}, //note: passes to @FormParams
              qguid: qguid,
              reFetch: reFetch,

              onResponse: function (rd, response, config) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.              

                  if (!thatVue.$th.haveError(true)) {

                    let thisIndex = thatVue.data_RS1.findIndex((el) => el.qguid === qguid)
                    if (thisIndex >= 0) {
                      thatVue.data_ThisRec = thatVue.data_RS1[thisIndex];

                    }

                    if (config && config.reFetch) {
                      thatVue.fetchRS1(config.qguid, config.reFetch);
                    }                    
                  }
                  
                  thatVue.decBusy();                    

                }
            });

            qguid = thatVue.dirtyQGUIDs.pop();

            //if (event.type == 'keyup') {
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

      onDropRec: function (evt) {
        let thatVue = this;
        
        let newIndex = evt.moved.newIndex;

        if (thatVue.data_RS1.length > 1) {
          if (newIndex == thatVue.data_RS1.length - 1) {
            //moved to end of list
            thatVue.data_RS1[newIndex - 1].NextQguid =  thatVue.data_RS1[newIndex].qguid;
            thatVue.setDirty(thatVue.data_RS1[newIndex - 1].qguid, 0, true);           
          }                    
          else {
            thatVue.data_RS1[newIndex].NextQguid =  thatVue.data_RS1[newIndex + 1].qguid;
            thatVue.setDirty(thatVue.data_RS1[newIndex].qguid, 0, true);          
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
</style>
