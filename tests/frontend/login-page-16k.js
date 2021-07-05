import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
  discardResponseBodies: true,
  stages: [
    { duration: '1m', target: 500 },
    { duration: '1m', target: 1000 },
    { duration: '1m', target: 2000 },
    { duration: '1m', target: 4000 },
    { duration: '1m', target: 8000 },
    { duration: '1m', target: 12000 },
    { duration: '1m', target: 16000 },
    { duration: '2m', target: 16000 },
    { duration: '1m', target: 12000 },
    { duration: '1m', target: 8000 },
    { duration: '1m', target: 4000 },
    { duration: '1m', target: 2000 },
    { duration: '1m', target: 1000 },
    { duration: '1m', target: 500 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  http.get('https://staging-app.plio.in');
  sleep(1);
}
