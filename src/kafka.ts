import { Kafka, logLevel } from 'kafkajs';

function env(key: string) {
  return (process.env[key] ?? '').trim();
}

function normalizeBroker(broker: string) {
  // Railway uses INTERNAL://kafka.railway.internal:29092
  if (!broker) return '';
  return broker.replace(/^INTERNAL:\/\//i, '');
}

export function kafkaEnabled() {
  return Boolean(env('KAFKA_BROKER') || env('KAFKA_BROKERS'));
}

export function kafkaTopic() {
  return env('KAFKA_TOPIC') || 'voyager.tweets';
}

const brokersRaw = env('KAFKA_BROKERS') || env('KAFKA_BROKER');
const brokers = brokersRaw
  ? brokersRaw
      .split(',')
      .map((s) => normalizeBroker(s.trim()))
      .filter(Boolean)
  : [];

const kafka = new Kafka({
  clientId: env('KAFKA_CLIENT_ID') || 'x-tweet-tracker-api',
  brokers,
  logLevel: logLevel.NOTHING,
});

let producerPromise: Promise<ReturnType<typeof kafka.producer>> | null = null;

async function getProducer() {
  if (!producerPromise) {
    const p = kafka.producer();
    producerPromise = p.connect().then(() => p);
  }
  return producerPromise;
}

export type KafkaTweetEvent = {
  type: 'tweet.upserted';
  tweetId: string;
  accountId: string;
  xUsername: string | null;
  createdAt: string;
  text: string;
  url: string;
};

export async function publishTweets(events: KafkaTweetEvent[]) {
  if (!kafkaEnabled()) return { ok: false, skipped: true as const };
  if (!events.length) return { ok: true, sent: 0 };

  const producer = await getProducer();

  await producer.send({
    topic: kafkaTopic(),
    messages: events.map((e) => ({
      key: e.tweetId,
      value: JSON.stringify(e),
    })),
  });

  return { ok: true, sent: events.length };
}
