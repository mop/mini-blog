function markdown_preview(url, elem, preview, link) {
  new Ajax.Request(url, {
    parameters: { markdown: $(elem).value },
    method: 'post',
    onSuccess: function (result) {
      var data = result.responseText
      new Effect.Parallel([
        new Effect.Move(elem, { x:100, mode: 'relative', sync: true }),
        new Effect.Fade(elem, { sync: true }),
        new Effect.Fade(link.up(), { sync: true })
      ], {
        afterFinish: function () {
          new Effect.Move(preview, { x: -100, mode: 'relative', duration: 0 });
          $(preview).update(data);
          new Effect.Parallel([
            new Effect.Move(preview, { x:0, mode: 'absolute', sync: true }),
            new Effect.Appear(preview, { sync: true }),
            new Effect.Appear(link.up(), { sync: true })
          ]);
          $(link).update("Hide");
          $(link).onclick = function() {
            markdown_fade(url, elem, preview, link);
          }
        }
      });
    } 
  })
}

function markdown_fade(url, elem, preview, link)
{
  new Effect.Parallel([
      new Effect.Move(preview, { x: 100, mode: 'relative', sync: true }),
      new Effect.Fade(preview, { sync: true }),
      new Effect.Fade(link.up(), { sync: true })
  ], {
    afterFinish: function() {
      new Effect.Move(elem, { x: -100, mode: 'absolute', duration: 0 });
      new Effect.Parallel([
        new Effect.Move(elem, { x: 0, mode: 'absolute', sync: true }),
        new Effect.Appear(elem, { sync: true }),
        new Effect.Appear(link.up(), { sync: true })
      ]);
      $(link).update("Preview");
      $(link).onclick = function() {
        markdown_preview(url, elem, preview, link);
      }
    }
  });
}

function delete_link(elem) {
  var url = elem.href.replace(/http:\/\/.+?\//, "/");
  var f = document.createElement('form');
  f.style.display = 'none';
  elem.parentNode.appendChild(f);
  f.method = 'post';
  f.action = url;
  var m = document.createElement('input');
  m.setAttribute('type', 'hidden');
  m.setAttribute('name', '_method');
  m.setAttribute('value', 'delete');
  f.appendChild(m);
  f.submit();
  return false;
}

Event.observe(window, 'load', function() {
  $$('.delete').each(function(elem) {
    Event.observe(elem, 'click', function(e) {
      if (!confirm("Are you sure?")) {
        Event.stop(e);
        return false;
      }
      Event.stop(e);
      return delete_link(elem);
    });
  });
  $$('.delete-noconfirm').each(function(elem) {
    Event.observe(elem, 'click', function(e) {
      Event.stop(e);
      return delete_link(elem);
    });
  });
});

