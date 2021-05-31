#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

#include <ck_ring.h>

ck_ring_t ring;
ck_ring_buffer_t *ring_buffer;

static void *
thread(void *arg __attribute__((unused)))
{
    int *data;

    // printf(" %d ", *(int *)arg);

    for(;;) {
        while (ck_ring_dequeue_spmc(&ring, ring_buffer, &data) == false);
        if (*data == 0) {
            free(data);
            return NULL;
        }
    }
    free(data);
    return NULL;
}

int
main(int argc, char **argv)
{
    assert(argc == 4);
    int rv;
    int iter = atoi(argv[1]);
    int qsize = atoi(argv[2]);
    int workers = atoi(argv[3]);
    pthread_attr_t attr;
    pthread_t threads[workers];
    clock_t start = clock();
    double duration;

    assert(qsize >= 4);
    assert(pthread_attr_init(&attr) == 0);

    ring_buffer = malloc(sizeof(void*) * qsize);
    assert(ring_buffer);
    ck_ring_init(&ring, qsize);

    for (int i=0; i < workers; i++) {
        int *arg = (int *)malloc(sizeof(int));
        *arg = i;
        rv = pthread_create(&threads[i], &attr, &thread, (void *)arg);
        assert(rv == 0);
    }

    assert(pthread_attr_destroy(&attr) == 0);

    for (int i=1; i <= iter ; i++) {
        int *value = (int *)malloc(sizeof(int));
        *value = i;
        while (ck_ring_enqueue_spmc(&ring, ring_buffer, value) == false);
    }

    for (int i=0; i < workers; i++) {
        int *value = (int *)malloc(sizeof(int));
        *value = 0;
        while (ck_ring_enqueue_spmc(&ring, ring_buffer, value) == false);
    }

    for (int i=0; i < workers; i++) {
        rv = pthread_join(threads[i], NULL);
        assert(rv == 0);
    }
    duration = (double)(clock() - start) / CLOCKS_PER_SEC;
    printf("%d, %d, %2.0f\n", workers, qsize, (double)iter/duration);
}
