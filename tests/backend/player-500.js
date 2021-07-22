import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { randomIntBetween, randomItem } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";

export let options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '30s', target: 50 },
    { duration: '30s', target: 200 },
    { duration: '30s', target: 500 },
    { duration: '30s', target: 500 },
    { duration: '30s', target: 200 },
    { duration: '30s', target: 50 },
    { duration: '30s', target: 20 },
    { duration: '60s', target: 0 },
  ],
};

let apiEndpoint = 'https://staging-backend.plio.in/api/v1';

let token = __ENV.ACCESS_TOKEN;
if (!token) {
    throw new Error("No access token provided!");
}

var plioUuid = 'jdzdfnaznb'; // or some other plio
var params = {
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
    },
    timeout: '600s'
};

export default function (data) {
    let plioPlayEndpoint = apiEndpoint + `/plios/${plioUuid}/play/`;
    let itemsEndpoint = apiEndpoint + `/items?plio=${plioUuid}/`;
    let sessionsEndpoint = apiEndpoint + '/sessions/';
    let eventsEndpoint = apiEndpoint + '/events/';

    // request plio
    let plioResponse = http.get(plioPlayEndpoint, params);
    if (plioResponse.status != 200) {
        console.log("plioResponse");
        console.log(plioResponse.status);
    }
    let plio = plioResponse.json()
    check(plioResponse, {
        'plio get responses have status 200': (response) => response.status === 200,
    });

    // request plio items
    let itemResponse = http.get(itemsEndpoint, params);
    check(itemResponse, {
        'item get responses have status 200': (response) => response.status === 200,
    });
    if (itemResponse.status != 200) {
        console.log("itemResponse");
        console.log(itemResponse.status);
    }

    // create user session
    let sessionPayload = {
        'plio': plio.id,
    };
    let sessionCreateResponse = http.post(sessionsEndpoint, JSON.stringify(sessionPayload), params);
    if (sessionCreateResponse.status != 201) {
        console.log("sessionCreateResponse");
        console.log(sessionCreateResponse.status);
    }
    let session = sessionCreateResponse.json();
    check(sessionCreateResponse, {
        'session create responses have status 201': (response) => response.status === 201,
    });

    let eventTypes = ['watching', 'question_proceed', 'question_answered', 'paused', 'video_seeked'];
    let eventPayload = {
        'details': {},
        'player_time': randomIntBetween(1, 10),
        'session': session.id,
        'type': randomItem(eventTypes),
    };

    // create random number of user generated events
    let random = randomIntBetween(5, 10);
    for (let count = 1; count <= random; count++) {
        eventPayload['type'] = randomItem(eventTypes);
        let eventCreateResponse = http.post(eventsEndpoint, JSON.stringify(eventPayload), params);
        if (eventCreateResponse.status != 201) {
            console.log("eventCreateResponse");
            console.log(eventCreateResponse.status);
        }
        check(eventCreateResponse, {
            'event create responses have status 201': (response) => response.status === 201,
        });
        sleep(1);
    }

    sessionPayload = {
        plio: plio.id,
        retention: "1",
        watch_time: 99,
    }

    // update user session random times
    random = randomIntBetween(5, 10);
    for (let count = 1; count <= random; count++) {
        sessionPayload['retention'] = sessionPayload['retention'] + ',' + randomIntBetween(0, 3);
        let sessionUpdateResponse = http.put(sessionsEndpoint + `${session.id}/`, JSON.stringify(sessionPayload), params);
        if (sessionUpdateResponse.status != 200) {
            console.log("sessionUpdateResponse");
            console.log(sessionUpdateResponse.status);
        }
        check(sessionUpdateResponse, {
            'session update responses have status 200': (response) => response.status === 200,
        });
        sleep(1);
    }

    sleep(10);
}
