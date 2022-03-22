#include <chrono>
#include <iostream>
#include <mutex>
#include <queue>
#include <random>
#include <stdio.h>
#include <thread>
#include <condition_variable>
#include <vector>
using namespace std;

struct Buffer {
  mutex mut;
  queue<int> produce_queue;
  condition_variable cond;
};

void product(Buffer *buffer) {
  while (true) {
    lock_guard<mutex> lg(buffer->mut);
    buffer->produce_queue.push(0);
    buffer->cond.notify_all();
  }
}

void consume(Buffer *buffer, int id) {
  while (1) {
    unique_lock<mutex> ul(buffer->mut, try_to_lock);
    if (ul.owns_lock()) {
      buffer->cond.wait(ul, [buffer]() -> bool { return !buffer->produce_queue.empty(); });
      buffer->produce_queue.pop();
    }
    ul.unlock();
  }
}

int main() {
  Buffer *buffer = new Buffer();
  thread t1(&product, buffer);

  for (int i = 1; i <= 10; i++) //十个消费者
  {
    thread t2(&consume, buffer, i);
    t2.detach();
  }
  t1.join();
  return 0;
}
