This is a simple example of using vue.js and async fetching of data.

There are three files involved:
  vue1  (could be named vue1.html) is the HTML file requested by the user.  Should only contain non-dynamic static content.
  vue1.js The main purpose is to load the required .vue file:  initializes the vue instance, import the .vue file, and thisVue.$mount(`#thapp`);
  vue1_App.vue is a single-file vue file containing the HTML template, the Javascript, and the scoped CSS for this component (i.e. the main application)
