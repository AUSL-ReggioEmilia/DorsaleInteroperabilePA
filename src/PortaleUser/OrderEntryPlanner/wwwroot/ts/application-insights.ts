import { AppInsights } from 'applicationinsights-js';

//
//Singleton per application insights.
//In questo modo riesco ad accedere alla variabile "AppInsights" da ovunque senza dover ricavare sempre l'instrumentation key.
//
export class SingletonAppInsights {
    private static instance: SingletonAppInsights;

    public readonly appInsights: Microsoft.ApplicationInsights.IAppInsights;

    private constructor() {
        $.ajax({
            type: "GET",
            url: "../Components/AjaxWebMethod.asmx/GetInstrumentationKey",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {
                AppInsights.downloadAndSetup({ instrumentationKey: result.d });
            }
        });

        this.appInsights = AppInsights;

        this.appInsights.queue.push(() => {
            appInsights.context.addTelemetryInitializer((envelope) => {
                envelope.tags["ai.cloud.role"] = "OePlanner-User";
            })
        });
    }

    static getInstance() {
        if (!SingletonAppInsights.instance) {
            SingletonAppInsights.instance = new SingletonAppInsights();
        }

        return SingletonAppInsights.instance;
    }
}