export default {
    delimiters: ["[[", "]]"],

    props: {
        // Note:  message may be set to a pipe-delimited multi-part string like this:
        //'Some tech stuff|A friendly message|1|My Title'
        // 0: Technical message
        // 1: Friendly message
        // 2: Flag to indicate that technical message should be displayed
        // 3: Title for modal
        message: {
          type: String,
          required: false
        }
    },

    template: `
            <b-modal ref="thModal"
                     :title="modal_Title"
                     centered
                     v-model="haveError"
                     @hidden="onModalHide">

                <div>
                    <p class="text-center" v-html="modal_Body">
                    </p>
                </div>

                <div v-if="modal_Tech != ''">
                    <b-collapse id="collapseTechInfo">
                        <b-card class="text-center font-italic " v-html="modal_Tech">                  
                        </b-card>                    
                    </b-collapse>
                </div>

               <div slot="modal-footer" class="w-100">
                 <!--
                 <b-btn size="sm" variant="secondary" @click="onClickLogout">
                   Logout
                 </b-btn>
                 -->
                 
                 <b-btn size="sm" variant="primary" @click="onClickCloseModal">
                   OK
                 </b-btn>
                 
                 <b-btn size="sm" variant="info" v-b-toggle.collapseTechInfo>
                   More Info
                 </b-btn>                 
               </div>

            </b-modal>
  `,
    data() {
        let thisData = {
            //message: 'Oh hai from the component'
        };

        return thisData;
    },

    computed: {
        // haveError is to cause the error modal to be displayed.
        // The modal will try to update the v-model that is set to
        // haveError, but really it is a read-only property.

        haveError: {
            get()
            {
                let thatVue = this;

                let result = false;

                if (thatVue.message && thatVue.message.length > 0) {
                    result = true;
                }

                return result
            }
            ,
            set(value)
            {
                let thatVue = this;

                // We don't really need to do anything...
                // but haveError must be settable since we assign
                // haveError to the modal's v-model attribute.
            }
        }
        ,

        // computed properties to parse out the error modal's content from
        // this.message

        modal_Body: function () {
            let thatVue = this;

            let result = '';

            if (thatVue.message) {
                let msg = thatVue.message.replace(/\\n/g, '<br />');
                let msgParts = msg.split('|');
                result = msgParts[1] ? msgParts[1] : msgParts[0];
            }

            return result;
        }
        ,

        modal_Title: function () {
            let thatVue = this;

            let result = '';

            if (this.message) {
                let msg = thatVue.message.replace(/\\n/g, '<br />');
                let msgParts = msg.split('|');
                result = msgParts[3] ? msgParts[3] : 'Error';
            }

            return result;
        }
        ,

        modal_Tech: function () {
            let thatVue = this;

            let result = '';

            if (thatVue.message) {
                let msg = thatVue.message.replace(/\\n/g, '<br />');
                let msgParts = msg.split('|');
                result = msgParts[2] == '1' && msgParts[1] != '' ? msgParts[0] : '';
            }

            return result;
        },

    },

    methods: {
        // the error modal provides a button for "Logout".  Handle clicks.
        onClickLogout: function () {
            let thatVue = this;

            window.location = '/logout';
        },

        // The error modal can be closed in several different ways.
        // When it closes, clear the error.
        onModalHide: function () {
            let thatVue = this;

            // clear the error message (locally, and on the server)
            //thatVue.th.clearError();
            //onClear();
            thatVue.$emit('clear-error');
            //thatVue.message = '';
        },

        // We are using a custom "close" button on the error message
        // modal, so we need to handle the click event that closes the
        // modal.
        onClickCloseModal: function () {
            let thatVue = this;

            // unfortunately, there is no way to programatically close
            // the modal without getting a reference to it from the DOM.
            let modal = thatVue.$refs.thModal;

            if (modal) {
                modal.hide();
            }
        }
    }


};

