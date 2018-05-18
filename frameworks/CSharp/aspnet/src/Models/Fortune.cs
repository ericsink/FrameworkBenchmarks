using System;

namespace Benchmarks.AspNet.Models
{
    public class Fortune : IComparable<Fortune>
    {
        public int Id { get; set; }
        public string Message { get; set; }
        
        public int CompareTo(Fortune other)
        {
            return String.CompareOrdinal(Message, other.Message);
        }
    }
}