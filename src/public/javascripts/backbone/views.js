Conductor.Views = Conductor.Views || {}


Conductor.Views.PoolsIndex = Backbone.View.extend({
  el: '#content',

  currentTab: function() {
    if($('#details_pools.active').length > 0) {
      return 'pools';
    }
    else if ($('#details_deployments.active').length > 0) {
      return 'deployments';
    }
    else if ($('#details_instances.active').length > 0) {
      return 'instances';
    }
  },

  template: function() {
    switch(this.currentTab()) {
      case 'pools': return $('#poolTemplate');
      case 'deployments': return $('#deploymentTemplate');
      case 'instances': return $('#instanceTemplate');
    }
  },

  render: function() {
    var $template = this.template();
    var $table = this.$('table.checkbox_table > tbody');
    if($table.length === 0 || $template.length === 0) return;

    var checkboxes = Conductor.saveCheckboxes('td :checkbox', $table);
    $table.empty().append($template.tmpl(this.collection.toJSON()))
    Conductor.restoreCheckboxes(checkboxes, 'td :checkbox', $table);
  },
});

Conductor.Views.PoolsShow = Backbone.View.extend({
  el: '#content',

  currentTab: function() {
    if($('#details_deployments.active').length > 0) {
      return 'deployments';
    }
    else if ($('#details_properties.active').length > 0) {
      return 'properties';
    }
    else if ($('#details_images.active').length > 0) {
      return 'images';
    }
  },

  render: function() {
    this.$('h1.pools').text(this.model.get('name') + ' Pool');

    var $template = $('#deploymentTemplate');
    if($template.length === 0) return;

    var $table = this.$('table.checkbox_table > tbody');
    var deployments = this.model.get('deployments');
    if($table.length !== 0) {
      var checkboxes = Conductor.saveCheckboxes('td :checkbox', $table);
      $table.empty().append($template.tmpl(deployments))
      Conductor.restoreCheckboxes(checkboxes, 'td :checkbox', $table);
    }
    else {
      var $cards = this.$('ul.deployable-cards').empty()
      var cardsPerRow = 5;
      for(var i = 0; i < deployments.length; i += cardsPerRow) {
        var $row = this.make('ul',
          {class: 'deployment-array large'},
          $template.tmpl(deployments.slice(i, i + cardsPerRow)));
        $cards.append($row);
      }
    }
  },
});


Conductor.Views.DeploymentsShow = Backbone.View.extend({

  el: '#content',

  render: function() {
    var $instances = this.$('ul.instances_list');
    if($instances.length === 0) {
      $instances = this.$('table.checkbox_table > tbody');
    }
    if($instances.length === 0) return;

    var checked_instances = Conductor.saveCheckboxes('td :checkbox', $instances);
    $instances.empty();
    $('#instanceTemplate').tmpl(this.collection.toJSON()).appendTo($instances);
    Conductor.restoreCheckboxes(checked_instances, 'td :checkbox', $instances);
    $instances.find('tr:even').addClass('nostripe');
    $instances.find('tr:odd').addClass('stripe');
  },

});
