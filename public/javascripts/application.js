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

  onSuccess: function(cb) {
    this.callback = cb;
  },

  formElements: function() {
    var id = this.id.toString();
    var elements = [ 'name', 'url', 'mail' ].map(function(name) {
      var val = this[name];
      if (val == undefined) val = '';
      return new Element('input', { 
        name: 'comment[name]',
        value: val,
        id: 'comment_' + id + '_' + name 
      });
    });

    elements[elements.length] = new Element('textarea', {
      name: 'comment[text]',
      id: 'comment_' + id + '_text'
    }) 
    elements[elements.length - 1].insert(this.text);
    return elements;
  },

  formLabels: function() {
    var id = this.id.toString();
    return [ 'name', 'url', 'mail', 'text'].map(function(name) {
      var label = new Element('label', { 
        for: 'comment_' + id + '_' + name 
      });
      label.insert(name);
      return label;
    });
  },

  fetch: function() {
    var comment = this;
    new Ajax.Request(this.url, {
      method: 'get',
      onSuccess: function(response) {
        comment.text = response.responseText;
        comment.callback();
      }
    });
  },
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
      new Effect.Move(elem, { x: -100, mode: 'absolute', duration: 0 });
      new Effect.Parallel([
        new Effect.Move(elem, { x: 0, mode: 'absolute', sync: true }),
        new Effect.Appear(elem, { sync: true }),
        new Effect.Appear(link.up(), { sync: true })
      ]);
      $(link).update("Preview");
      $(link).onclick = function() {
        markdown_preview(url, elem, preview, link);
        return false;
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

/**
 * Returns the id of the current entry
 */
function entry_id() {
  return $$('h2 a')[0].getAttribute("id").replace(/entry_/, '');
}

function ajaxify_edit_form(form) {
  var button = $(form.getElementsByTagName('button')[0]);
  Event.observe(button, 'click', function(e) {
    var content = Form.serialize(form);
    new Ajax.Request(form.getAttribute('action') + '.js', {
      method: 'post',
      parameters: content,
      onSuccess: function(result) {
        form.previous().previous().previous().insert({
          before: result.responseText
        });
        var updated_element = form.previous().previous().previous().previous();
        updated_element.select('a').each(ajaxify_edit);
        new Effect.Highlight(updated_element);
        form.previous().remove();   // <h3>
        form.previous().remove();   // <br/>
        form.previous().remove();   // <div>
        form.remove();
      },
    });
    Event.stop(e);
  });
}

function ajaxify_edit(elem) {
  if (!elem.match(/\/edit$/)) return;
  Event.observe(elem, 'click', function(e) {
    var url = elem.href.replace(/http:\/\/.+?\//, "/");
    var comment = new Comment(url);
    comment.onSuccess(function() {
      var div = elem.up('.comment');
      div.hide();
      var br   = new Element('br');
      div.insert({before: br});
      div.insert({after: comment.text});
      ajaxify_edit_form(div.next().next());
    });
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

  $$('#comments button').each(ajaxify_create);
  $$('#comments a').each(ajaxify_edit);
});

