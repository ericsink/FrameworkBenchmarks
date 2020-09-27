// Copyright (c) .NET Foundation. All rights reserved. 
// Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information. 

using System;
using System.Runtime.CompilerServices;
using System.Threading;

namespace PlatformBenchmarks
{
    public class ConcurrentRandom
    {
        private static uint nextSeed = 0;

        [ThreadStatic]
        private static ConcurrentRandom _random;

        private UInt128 _state;

        private static ConcurrentRandom Random => _random ?? CreateRandom();

        private ConcurrentRandom(UInt128 state)
        {
            _state = state;
        }

        [MethodImpl(MethodImplOptions.NoInlining)]
        private static ConcurrentRandom CreateRandom()
        {
            var seed = Interlocked.Increment(ref nextSeed);
            _random = new ConcurrentRandom(new UInt128(splitmix64_stateless(seed + 1), splitmix64_stateless(seed)));
            return _random;
        }

        public static int Next() => Random.NextImpl();

        private int NextImpl()
        {
            // Adapted from https://lemire.me/blog/2019/03/19/the-fastest-conventional-random-number-generator-that-can-pass-big-crush/

            const uint mask = 0x3FFF;
            ulong rand;
            do
            {
                _state *= 0xda942042e4dd58b5;
                rand = _state.High & mask;
            }
            while (rand > 10_000);

            return (int)(uint)rand + 1;
        }

        private static ulong splitmix64_stateless(ulong index)
        {
            ulong z = (index + 0x9E3779B97F4A7C15UL);
            z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9UL;
            z = (z ^ (z >> 27)) * 0x94D049BB133111EBUL;
            return z ^ (z >> 31);
        }

        private readonly struct UInt128
        {
            public readonly ulong Low;
            public readonly ulong High;

            public UInt128(ulong low, ulong high)
            {
                Low = low;
                High = high;
            }

            public static UInt128 operator *(UInt128 left, ulong right)
            {
                ulong high = Math.BigMul(left.Low, right, out ulong low);
                high += (left.High * right);
                return new UInt128(low, high);
            }

            //public static UInt128 operator*(UInt128 left, UInt128 right)
            //{
            //    ulong high = Math.BigMul(left.Low, right.Low, out ulong low);
            //    high += (left.High * right.Low) + (left.Low * right.High);
            //    return new UInt128(low, high);
            //}
        }
    }
}
