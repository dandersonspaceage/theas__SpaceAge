<template>
    <b-container id="NewPage1_Appvue" fluid="lg" style="padding: 0" class="fullheight">

        <b-row no-gutters fluid>
            <b-col cols="12">
                <h3>A sample Vue component</h3>
                <p>This is red</p>
            </b-col>
        </b-row>

        <b-row no-gutters class="fullheight">
            <b-col cols="12" class="fullheight">
                <h3>Hello from VSCode!</h3>
               <div class="fullheight">
               <TestBSVTable class="fullheight"></TestBSVTable>
               </div>
            </b-col>
        </b-row>


  <b-container>

</template>
 
<script>
    import TestBSVTable from  "{{ '/test/TestBSVTable.vue'|theasResource }}";

 
    export default {
        components: {
            TestBSVTable
        },
        data: function () {
            return {
                placeholder: 1

            }
        },

    }
</script>

<style>
    h1   {color: blue;}
    p    {color: red;}    
</style>

