/**
 * This class represents an comment and is used to fetch comments via json
 */
var Comment = Class.create({
  /**
   * Initializes the comment via an URL of the comment
   */
  initialize: function(url) {
    this.url  = url;
  },

  fetch: function() {
    var comment = this;
    var time = new Date().getTime();
    new Ajax.Request(this.url + "?time=" + time, {
      method: 'get',
      evalScripts: true,
      asynchronous: true
    });
  }
});

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
            return false;
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
      var cache = $(elem).value;
      new Effect.Move(elem, { x: -100, mode: 'absolute', duration: 0 });
      new Effect.Parallel([
        new Effect.Move(elem, { x: 0, mode: 'absolute', sync: true }),
        new Effect.Appear(elem, { sync: true }),
        new Effect.Appear(link.up(), { sync: true })
      ], {
        afterFinish: function() {
          $(elem).value = cache;      // I hate you Safari!!!11
        }
      });
      $(link).update("Preview");
      $(link).onclick = function() {
        markdown_preview(url, elem, preview, link);
        return false;
      }
      $(elem).select();
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

function ajaxify_edit(elem) {
  if (!elem.match(/\/edit$/)) return;
  Event.observe(elem, 'click', function(e) {
    var url = elem.href.replace(/http:\/\/.+?\//, "/");
    var comment = new Comment(url);
    comment.fetch();
    Event.stop(e);
  });
}

function insert_preview(elem) {
  var prefix = elem.up('form').getAttribute('action').replace(
    /\/?(.*?)\/entries\/\d+\/comments/, "/$1"
  ); // filter the prefix 
  if (prefix == '/') prefix = '';
  var div  = new Element('div', { 
    id: 'comment_preview',
    style: 'clear:both;' 
  });
  var link = new Element('a', {
    href: (prefix + '/markdown_preview/preview'),
    style: 'float:left;'
  });
  link.insert('Preview');

  elem.insert({ before: div });
  elem.insert({ after: link });

  nbsp = new Element('span', { style: 'float: left;' });
  nbsp.update('&nbsp;&nbsp;');
  link.insert({ before: nbsp });

  link.onclick = function() {
    markdown_preview(link.href, 'comment_text', 'comment_preview', link);
    return false;
  }
}

function ajaxify_create(elem) {
  var f = $$('#comments form').first();
  if (f.getAttribute('class') == 'comment_form') return;
  insert_preview(elem);
  Event.observe(elem, 'click', function(e) {
    var form = $$('#comments form')[0];
    var content = Form.serialize(form);
    new Ajax.Request(form.getAttribute('action') + '.js', {
      method: 'post',
      parameters: content,
      onSuccess: function(result) {
        form.previous().previous().insert({
          before: result.responseText
         });
        var new_element = form.previous().previous().previous();
        new Effect.Highlight(new_element);
        new_element.select('a').each(ajaxify_edit);
    }});
    Event.stop(e);
    return false;
  })
}

function ajaxify_check_box(form) {
  $(form).select('input[type="submit"]').each(function(e) {
    e.hide();
  });

  var link = form.getAttribute('action');
  $(form).select('input[type="checkbox"]').each(function(e) {
    Event.observe(e, 'click', function(ev) {
      var content = Form.serialize(form);
      new Ajax.Request(form.getAttribute('action') + '.js', {
        method: 'put', 
        parameters: content, 
        evalJS: false,
        onSuccess: function(result) {
          new Effect.Highlight(form);
        }
      });
    });
  });
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

  $$('#comments input[type="submit"]').each(ajaxify_create);
  $$('#comments a').each(ajaxify_edit);
  $$('.comment_form').each(ajaxify_check_box);
});

