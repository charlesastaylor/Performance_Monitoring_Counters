//
// Compare branch misses / instructions when summing an array of random data vs sorted data. Based on SumArray example
// from miniperf_example.c. Test simultaneously on a number of threads.
//
// NOTE(Charles): The example says we should get 20% misrate for the random array but we actually get ~16%, I guess
// our code has an extra branch in there somewhere? I'd have to get picky about compile settings and look at output code
// if wanted to confirm.
//

#import,dir "../../Performance_Monitoring_Counters";

main :: () {
    EXIT_FAILURE :: 1;

    if !is_pmc_collection_supported() {
        exit(EXIT_FAILURE);
    }

    // The pmcs to collect
    intel_pmc_names := string.[
        "BranchInstructions",
        "BranchMispredictions",
    ];

    amd_pmc_names := string.[
        "BranchInstructions",
        "BranchMispredictions",
    ];

    #import "Machine_X64";
    cpu_info := get_cpu_info();

    pmc_names: [] string;
    if cpu_info.vendor ==  {
        case .INTEL; pmc_names = intel_pmc_names;
        case .AMD;   pmc_names = amd_pmc_names;
        case;
            assert(false, "Unknown CPU vendor %", cpu_info.vendor);
    }

    success, pmc_sources := map_pmc_names(pmc_names);
    if !success {
        log_error("Failed to map one or more of pmc_names == %", pmc_names);
        exit(EXIT_FAILURE);
    }

    if !start_tracing(pmc_sources) {
        log_error("Failed to start_tracing");
        exit(EXIT_FAILURE);
    }


    DEBUG_ON_MAIN_THREAD :: false;
    #if DEBUG_ON_MAIN_THREAD {
        print("Counting branch mispredictions when summing a random array vs a sorted array...\n");
        sum_array_thread_proc(null);
    } else {
        THREAD_COUNT :: 16;
        threads: [THREAD_COUNT] Thread;
        print("Counting branch mispredictions when summing a random array vs a sorted array on % threads...\n", THREAD_COUNT);

        for * threads {
            thread_init(it, sum_array_thread_proc);
            thread_start(it);
        }

        // Wait for all threads to finish
        for * threads {
            done := thread_is_done(it, -1);
            assert(done, "thread_is_done returned false?!");
        }
    }

    stop_tracing();

    print("Done!\n");
}

sum_array_thread_proc :: (thread: *Thread) -> s64 {
    random_traced_thread: PMC_Traced_Thread;
    sorted_traced_thread: PMC_Traced_Thread;

    SUM_COUNT :: 100 * 1000 * 1000;
    // SUM_COUNT :: 10000;
    array := NewArray(SUM_COUNT, u8);

    randomize_array(array);
    {    
        CountPmcsScoped(*random_traced_thread);
        sum_array(array);
    }

    sort_array(array);
    {    
        CountPmcsScoped(*sorted_traced_thread);
        sum_array(array);
    }

    // We just wait_for_result on each thread. Use builder so we output per thread all at same time.
    builder: String_Builder;

    print_to_builder(*builder, "--- Results for thread % ---\n", context.thread_index);
    {
        result := wait_for_result(*random_traced_thread);
        branch_count  := result.pmc_values[0];
        branch_misses := result.pmc_values[1];
        // The number of branches/misses could be formatted nicely, eg round to Mega, Kilo etc.
        print_to_builder(*builder, "[%] [%s] sum on random array, branch misses = %0%%, % of % total\n",
                context.thread_index,
                formatFloat(result.time_taken, width = 6, trailing_width = 3),
                formatFloat(branch_misses * 100.0 / branch_count, width = 6, trailing_width = 2),
                formatInt(branch_misses, digits_per_comma = 3, comma_string = ","),
                formatInt(branch_count , digits_per_comma = 3, comma_string = ","),
                // formatInt(branch_misses / 1000000, minimum_digits = 2),
                // formatInt(branch_count  / 1000000, minimum_digits = 3),
                );
    }

    {
        result := wait_for_result(*sorted_traced_thread);
        branch_count  := result.pmc_values[0];
        branch_misses := result.pmc_values[1];
        print_to_builder(*builder, "[%] [%s] sum on sorted array, branch misses = %0%%, % of % total\n",
                context.thread_index,
                formatFloat(result.time_taken, width = 6, trailing_width = 3),
                formatFloat(branch_misses * 100.0 / branch_count, width = 6, trailing_width = 2),
                formatInt(branch_misses, digits_per_comma = 3, comma_string = ","),
                formatInt(branch_count , digits_per_comma = 3, comma_string = ","),
                // formatInt(branch_misses / 1000, minimum_digits = 2),
                // formatInt(branch_count  / 1000000, minimum_digits = 3),
                );
    }

    s := builder_to_string(*builder);
    write_string(s);

    return 0;
}

// Sorts array with counting sort
sort_array :: (array: [] u8) {
    counts: [U8_MAX+1] u32;
    for array  counts[it] += 1;

    offset: u64;
    for i: 0..U8_MAX {
        for c: 1..counts[i] {
            array[offset] = cast(u8) i;
            offset += 1;
        }
    }
}

// Fill array with random values
randomize_array :: (array: [] u8) {
    random : u32 = 1;
    for * array {
        it.* = cast(u8)(random >> 24);
        random = 0x01000193 * random + 0x811c9dc5;
    }
}

sum_array :: (array: [] u8) {
    result: u64;

    for array {
        if it < 128  result += it;
    }
}
//~

#import "Basic";
#import "Math";
#import "Thread";
