<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">

    <!--meta data...optional-->
    <meta name="description" content="SpaceAge Synthetics Login">
    <meta name="keywords" content="Theas,OpsStream,UI,Spaceage">
    <meta name="author" content="github.com/davidrueter/theas">
    <meta name="apple-mobile-web-app-capable" content="yes">
        <!--
         https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariHTMLRef/Articles/MetaTags.html
         If content is set to yes, the web application runs in full-screen mode; otherwise, it does not. The default behavior is to use Safari to display web content.
         You can determine whether a webpage is displayed in full-screen mode using the window.navigator.standalone read-only Boolean JavaScript property.        
        -->
    <meta name="application-name" content="SpaceAge Synthetics Login">
    <meta name="apple-mobile-web-app-title" content="SpaceAge">

    <!--favicon resources.  Build with https://favicon.io or other or create by hand.
    More Info: 
    https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs
    See https://www.emergeinteractive.com/insights/detail/The-Essentials-of-FavIcons/
    https://medium.com/dev-channel/how-to-add-a-web-app-manifest-and-mobile-proof-your-site-450e6e485638
    -->    
    <link rel="icon" href="/favicon.ico" sizes="any"><!-- 32?32 -->
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png"><!-- 180?180 -->
    <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">    
    <link rel="manifest" href="/manifest.webmanifest">     

    <!--https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/dn255024(v=vs.85)?redirectedfrom=MSDN-->
    <meta name="msapplication-TileColor" content="#da532c">

    <!--https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta/name/theme-color-->
    <meta name="theme-color" content="#ffffff">

    <link type="text/css" rel="stylesheet" href="{{ 'cdn/bootstrap4/css/bootstrap.min.css'|theasResource }}">  

    <link type="text/css" rel="stylesheet" href={{ 'cdn/font-awesome/css/all.css'|theasResource }}>


    <title>SpaceAge Synthetics Login</title>

    <!--Static global styles-->
    <style>
      .fullheight {height: 100%}
      .fastscroll {overflow-y:scroll; -webkit-overflow-scrolling: touch;}
      
      .collapsed > .when-opened,
      .not-collapsed > .when-closed {
        display: none;
      }

    </style>

    <!--Global scripts-->
    <script nomodule>
        document.getElementById("thapp").innerHTML = "This application will not work with your browser because your browser doesn't support JavaScript modules.";
    </script>

    <script src="{{ '/cdn/axios/axios.min.js'|theasResource }}"></script>
    <script src="{{ '/cdn/hammerjs/hammer.min.js'|theasResource }}"></script>
    <script src="{{ '/cdn/moment/moment.js'|theasResource }}"></script>
    <script src="{{ '/cdn/screenfull/screenfull.js'|theasResource }}"></script>

    <script src="{{ '/cdn/vuejs/vue.js'|theasResource }}"></script>

    <script src="{{ '/cdn/popper.js/umd/popper.js'|theasResource }}"></script>
    <script src="{{ '/cdn/portal-vue/portal-vue.umd.min.js'|theasResource }}"></script>
    <script src="{{ '/cdn/bootstrap-vue/bootstrap-vue.js'|theasResource }}"></script>
    <script src="{{ '/theas/TheasVue.js'|theasResource }}"></script>

    <script  type="module" src="{{ '/login.js'|theasResource }}"></script>

</head>

<body style="height:85vh" class="bg-white">>

<div class="container">
  <div class="row">
    <div class="col-12">
      <form method="post" class="form-horizontal needs-validation" novalidate="" id="theasForm">
        {{ "__th"|theasXSRF }}
        {{ "__th"|theasSessionToken(vuejs=False) }}

          <div class="py-5 text-center">
              <h2>Login</h2>                    
          </div>

          <div class="row">
            <div class="col-md-12 order-md-1">
              <h4 class="d-flex justify-content-between align-items-center mb-3"><span class="text-muted">Heading</span></h4>


              <div class="row">
                  <div class="form-group col-md-12"><label class="control-label" for="ebUsername">User Name</label><input
                          id="ebUsername" name="u" class="form-control" type="text" />
                  </div>
              </div>
              <div class="row">
                  <div class="form-group col-md-12"><label class="control-label" for="ebUsername">Password</label><input
                          id="ebPassword" name="pw" class="form-control" type="password" />
                  </div>
              </div>

              <div class="row">
                  <div class="form-group col-md-12">
                                  <div class="custom-control custom-checkbox">
                                      <input name="theas:th:RememberUser" id="ckbxRememberUser" type="checkbox" default="1" class="custom-control-input _thControl" style="visibility:hidden" value="1" checked="checked">
                                      <label class="custom-control-label" for="ckbxRememberUser">Stay logged in on this machine</label>
                                  </div>
                  </div>
              </div>

              <div class="row">
                  <div class="form-group col-md-2">
                      <input type="submit" value="Login" />
                  </div>
              </div>



            </div>
          </div>

      </form>
    </div>
  </div>
</div>

<!-- Modal -->
<div id="thMsgModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="thMsgModalTitle" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="thMsgModalTitle">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <div class="modal-body">
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>


<!-- Placed at the end of the document so the pages display faster -->

<script src={{ '/cdn/jquery/jquery.min.js'|theasResource }}></script>
<script src={{ '/cdn/popper/popper.min.js'|theasResource }}></script>
<script src={{ '/cdn/bootstrap4/js/bootstrap.js'|theasResource }}></script>

<script src={{ '/cdn/jquery-validation/dist/jquery.validate.js'|theasResource }}></script>
<script src={{ '/cdn/Theas.js'|theasResource }}></script>

<!--script src={{ '/theastypeahead.js'|theasResource }}></script>-->

<script>
  $(document).ready(function () {

      // hide modal on Enter key.  May move this into theas.js
      $(document).keyup(function (e) {
          if (e.keyCode == 13) {
              $('.modal:visible').modal('hide');
          }
      });

      // Make sure Theas is ready.  (This also makes sure that jQuery is ready.)
      th.ready(function () {
          var that = this;

          // Our form fields are set persist="0" ... so technically they are not Theas params
          // (and they are accessed in @FormParams instead of @TheasParams in SQL).
          // Consequently, they are not automatically URL-decoded...so we need to decode these.
          th.decodeAll('CurReg:');


          // Rather than letting HTML submit the form, I prefer to submit it
          // programatically when the form submit button is clicked.

          $('#theasForm').on('submit', function (e) {
              if (!th.beforeSubmit()) {
                e.preventDefault();
                return(false);
              }
              else {
                return(true);
              }
          });


          if (!th.haveError(true)) {

              // Everything is ready and error-free.
              // You can do whatever you want to do here.  Both jQuery and Theas are ready for use.
              var placeholder;

          }
      });

  });

</script>

</body>

</html>
