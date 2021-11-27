<template>
    <div>
        <h1>Hail BSV1! Nice!</h1>
        <b-table
                responsive
                sticky-header="70vh"
                :items="data_Steps"
                :fields="fields_Steps"
        >
    </div>
</template>

<script>
    export default {
        data() {
            return {

                dataRefreshInterval: 15,
                enableFetching: true,

                // Dynamic data will be fetched asynchronously
                data_Steps: [],
                lastFetch_Steps: null,
                asyncResource_Steps: 'saltd/TestBSVTable.vue',
                asyncCmd_Steps: 'fetchSteps',

                fields_Steps: [
                    {key: 'StepID', stickyColumn: true, isRowHeader: true, variant: 'primary'},
                    'StepName'
                ],

                /*
        fields: [
          { key: 'id', stickyColumn: true, isRowHeader: true, variant: 'primary' },
          'a',
          'b',
          { key: 'c', stickyColumn: true, variant: 'info' },
          'd',
          'e',
          'f',
          'g',
          'h',
          'i',
          'j',
          'k',
          'l'
        ],
        items: [
          { id: 1, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 2, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 3, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 4, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 5, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 6, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 7, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 8, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 9, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 },
          { id: 10, a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11 }
        ]
*/

            }
        },   

        // method executed when the Vue object is created
        created: function () {

            // perform the initial fetch of data
           this.fetchData(true);

        },

        methods: {

            fetchSteps: function () {
                // save reference to Vue object
                let thatVue = this;

                thatVue.$th.sendAsync({
                    url: '/async/' + thatVue.asyncResource_Steps,
                    asyncCmd: thatVue.asyncCmd_Steps,
                    lastFetchDate: thatVue.lastFetch_Steps,

                    onResponse: function (rd, response) {
                        // rd contains the response data split into an object (of name/value pairs)
                        // (might have been returned as either a string of URL-encoded name/value
                        // pairs, or as a JSON strong)

                        // response contains the complete response object, in which .data contains
                        // the raw data that was received.

                        if (rd['Steps']) {
                            let thisObj = JSON.parse(rd['Steps'])[0];
                            let thisData = thisObj['JSONData'];
                            let thisFetchDate = thisObj['FetchDate'];

                            if (thisData) {
                                thatVue.data_Steps = thatVue.$th.merge(
                                    // string (optional): key field name with unique values to merge on
                                    'StepID',
                                    // string (optional): key value to exclude from merge (i.e. currently-displayed rows)
                                    //'someIDValue'
                                    thatVue.data_Steps,
                                    thisData);
                            }
                            thatVue.data_Steps = thatVue.$th.sortArray(thatVue.data_Steps, 'DateReceived', true);

                            if (thatVue.lastFetch_Steps) {
                                thatVue.lastFetch_Steps = thisFetchDate;
                            } else {
                                thatVue.lastFetch_Steps = '1/1/1900'
                            }
                        }

                    }

                });
            },

            fetchData: function (forceOnError) {
                let thatVue = this;

                // clear out any old, stuck, in-progress async requests
                thatVue.$th.cancelAsync(moment().subtract(30, 's'));  //cancel any request started more than 30 seconds ago

                // check th.loadingCount so we don't fire off too many simultaneous requests
                if (
                    (forceOnError || !this.$th.theasParams.th$ErrorMessage)
                    && thatVue.$th.loadingCount < 5
                ) {
                    if (thatVue.modalShowing === true) {
                        thatVue.enableFetching = false;
                    }

                    if (thatVue.enableFetching === true) {
                        thatVue.fetchSteps();
                        // can add additional fetches here
                    }
                }

            },

        }
    }
</script>
