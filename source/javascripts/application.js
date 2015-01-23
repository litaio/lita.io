//= require hljs

$(function () {
  $('code.language-ruby').each(function (_, el) {
    hljs.highlightBlock(el);
  });
});
