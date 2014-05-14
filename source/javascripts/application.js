//= require hljs

$(function () {
  $('code.ruby').each(function (_, el) {
    hljs.highlightBlock(el);
  });
});
