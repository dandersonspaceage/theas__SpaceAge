import vueNewPage1 from "{{ '/press/press_App.vue'|theasResource }}"

    // First we get the viewport height and we multiple it by 1% to get a value for a vh unit
    let vh = window.innerHeight * 0.01;
    // Then we set the value in the --vh custom property to the root of the document
    document.documentElement.style.setProperty('--vh', `${vh}px`);

    var gPageVariant = 'press';

    Vue.config.productionTip = false;

    Vue.use(BootstrapVue);

    const paperOptions = {
      name: '_blank',
      specs: [
        'fullscreen=yes',
        'titlebar=yes',
        'scrollbars=yes'
      ],
      styles: [
        //'https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css',
        //'https://unpkg.com/kidlat-css/css/kidlat.css'
      ],
      timeout: 1000, // default timeout before the print window appears
      autoClose: true, // if false, the window will not close after printing
      windowTitle: window.document.title, // override the window title
    };
    
    Vue.use(VueHtmlToPaper, paperOptions);

    Vue.prototype.$th = new Theas()

   //use Axios instead of vue-resource for HTTP calls as per https://medium.com/the-vue-point/retiring-vue-resource-871a82880af4
    Vue.prototype.$http = axios;

    Vue.directive('swipeleft', {
        bind: function (el, binding) {
            if (typeof binding.value === 'function') {

                const mc = new Hammer.Manager(el, {
                    touchAction: 'auto',
                    inputClass: Hammer.SUPPORT_POINTER_EVENTS ? Hammer.PointerEventInput : Hammer.TouchMouseInput,
                    recognizers: [
                        [Hammer.Swipe, {
                            direction: Hammer.DIRECTION_LEFT
                         }]
                     ]
                 });
                mc.on('swipeleft', binding.value);
            }
        }
    });

    Vue.directive('swiperight', {
        bind: function (el, binding) {
            if (typeof binding.value === 'function') {

                 const mc = new Hammer.Manager(el, {
                    touchAction: 'auto',
                    inputClass: Hammer.SUPPORT_POINTER_EVENTS ? Hammer.PointerEventInput : Hammer.TouchMouseInput,
                    recognizers: [
                        [Hammer.Swipe, {
                            direction: Hammer.DIRECTION_RIGHT
                         }]
                     ]
                 });
            
                mc.on('swiperight', binding.value);
            }
        }
    });

    if (!FormData.prototype.set) {
        FormData.prototype.set = FormData.prototype.append;
    }

    let thisVue = new Vue({
        delimiters: ["[[", "]]"],
        render: h => h(vueNewPage1),
    });

    // Set the reference to the vue object in this.th
    thisVue.$th.setVue(thisVue);
    
    thisVue.$mount(`#thapp`);
