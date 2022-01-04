<template>
    <b-container style="padding: 0">
        <b-row>
            <b-col>
                <b-row class="row form-group nopadding">
                    <b-col cols="12" md="6">


                        <b-form-fieldset description="Enter your user name." label="User Name" :label-cols="6">

                            <b-form-input v-model="theasParams.Login$UserName" type="text" placeholder="User name"
                                @keyup.enter.native="submitForm"></b-form-input>

                        </b-form-fieldset>


                        <b-form-fieldset description="Enter your password." label="Password" :label-cols="6">

                            <b-form-input v-model="theasParams.Login$Password" type="password" placeholder="Password"
                                @keyup.enter.native="submitForm"></b-form-input>

                        </b-form-fieldset>


                        <b-form-checkbox id="ckbxRememberUser" v-model="theasParams.th$RememberUser" value="1"
                            unchecked-value="1">
                            Keep me logged in on this computer
                        </b-form-checkbox>


                        <b-btn variant="success" @click.prevent="submitForm">Submit</b-btn>
                        <!--b-btn :variant="outline-warning" @click.prevent="cancelForm">Cancel</b-btn-->


                    </b-col>
                </b-row>

            </b-col>
        </b-row>

      <b-modal id="thModal" ref="thModal" :title="theasLastError.msgTitle" @hide="onthModalHide" hide-footer>
        <div class="d-block text-center">
          <h3>[[ theasLastError.msgFriendly ]]</h3>
          <i v-if="theasLastError.showTech">[[ theasLastError.msgTech ]]</i>        
        </div>
      </b-modal>

    </b-container>
    
</template>

<script>


  export default {
    delimiters: ["[[", "]]"],

    data() {
      return {
        theasParams: {},
        theasLastError: {},
    
        today: moment().toDate(),
        busyCount: 1,
        curCursor: 'progress',
       
        asyncResource: null,
        asyncCmd: null,

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

      formatDate: function (thisDate, thisFormatStr) {
        //if (typeof thisDate === 'string' || thisDate instanceof String) {
        //    thisDate = thisDate.replace('T', ' ');
        //}
        let result = moment(thisDate).format(thisFormatStr);
        return result;
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


      submitForm: function (e) {

          let thatVue = this;

          thatVue.$th.submitForm(thatVue, {url: '/login'});

/*
          thatVue.th.sendAsync({
              url: '/login',
              //asyncCmd: 'AsyncLogin',
              //data: {}, //note: passes to @FormParams

              onResponse: function (rd, response) {
                  // rd contains the response data split into an object (of name/value pairs)
                  // (might have been returned as either a string of URL-encoded name/value
                  // pairs, or as a JSON strong)

                  // response contains the complete response object, in which .data contains
                  // the raw data that was received.

                  if (thatVue.theasParams['th$LoggedIn'] == "1" &&
                      thatVue.theasParams['th$NextPage']) {
                      window.location = thatVue.theasParams['th$NextPage'];
                  }

              }
          });
*/

      }
  
    },
  };
</script>

