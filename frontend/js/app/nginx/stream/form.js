const Mn          = require('backbone.marionette');
const App         = require('../../main');
const StreamModel = require('../../../models/stream');
const template    = require('./form.ejs');

require('jquery-serializejson');
require('jquery-mask-plugin');
require('selectize');

module.exports = Mn.View.extend({
    template:  template,
    className: 'modal-dialog',

    ui: {
        form:       'form',
        forwarding_host: 'input[name="forwarding_host"]',
        type_error: '.forward-type-error',
        buttons:    '.modal-footer button',
        switches:   '.custom-switch-input',
        cancel:     'button.cancel',
        save:       'button.save'
    },

    events: {
        'change @ui.switches': function () {
            this.ui.type_error.hide();
        },

        'click @ui.save': function (e) {
            e.preventDefault();

            if (!this.ui.form[0].checkValidity()) {
                $('<input type="submit">').hide().appendTo(this.ui.form).click().remove();
                return;
            }

            let view = this;
            let data = this.ui.form.serializeJSON();

            if (!data.tcp_forwarding && !data.udp_forwarding) {
                this.ui.type_error.show();
                return;
            }

            // Manipulate
            data.forwarding_port = parseInt(data.forwarding_port, 10);
            data.tcp_forwarding  = !!data.tcp_forwarding;
            data.udp_forwarding  = !!data.udp_forwarding;

            let method = App.Api.Nginx.Streams.create;
            let is_new = true;

            if (this.model.get('id')) {
                // edit
                is_new  = false;
                method  = App.Api.Nginx.Streams.update;
                data.id = this.model.get('id');
            }

            this.ui.buttons.prop('disabled', true).addClass('btn-disabled');
            method(data)
                .then(result => {
                    view.model.set(result);

                    App.UI.closeModal(function () {
                        if (is_new) {
                            App.Controller.showNginxStream();
                        }
                    });
                })
                .catch(err => {
                    alert(err.message);
                    this.ui.buttons.prop('disabled', false).removeClass('btn-disabled');
                });
        }
    },

    initialize: function (options) {
        if (typeof options.model === 'undefined' || !options.model) {
            this.model = new StreamModel.Model();
        }
    }
});
