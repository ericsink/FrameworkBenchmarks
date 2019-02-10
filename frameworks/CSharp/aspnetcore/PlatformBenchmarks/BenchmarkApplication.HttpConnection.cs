// Copyright (c) .NET Foundation. All rights reserved.
// Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.

using System;
using System.Buffers;
using System.IO.Pipelines;
using System.Text.Encodings.Web;
using System.Text.Unicode;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Server.Kestrel.Core.Internal.Http;

namespace PlatformBenchmarks
{
    public partial class BenchmarkApplication : IHttpConnection
    {
        private State _state;

        public PipeReader Input { get; set; }

        private MemoryWriter Writer { get; set; }
        private PipeWriter _output;
        public PipeWriter Output
        {
            get => _output;
            set
            {
                _output = value;
                Writer = new MemoryWriter(value);
            }
        }

        protected HtmlEncoder HtmlEncoder { get; } = CreateHtmlEncoder();

        private HttpParser<ParsingAdapter> Parser { get; } = new HttpParser<ParsingAdapter>();

        public async Task ExecuteAsync()
        {
            try
            {
                await ProcessRequestsAsync();

                Input.Complete();
            }
            catch (Exception ex)
            {
                Input.Complete(ex);
            }
            finally
            {
                Output.Complete();
            }
        }

        private async Task ProcessRequestsAsync()
        {
            while (true)
            {
                var task = Input.ReadAsync();

                if (!task.IsCompleted)
                {
                    // No more data in the input
                    await OnReadCompletedAsync();
                }

                var result = await task;
                var buffer = result.Buffer;
                while (true)
                {
                    if (!ParseHttpRequest(ref buffer, result.IsCompleted, out var examined))
                    {
                        return;
                    }

                    if (_state == State.Body)
                    {
                        await ProcessRequestAsync();

                        _state = State.StartLine;

                        if (!buffer.IsEmpty)
                        {
                            // More input data to parse
                            continue;
                        }
                    }

                    // No more input or incomplete data, Advance the Reader
                    Input.AdvanceTo(buffer.Start, examined);
                    break;
                }
            }
        }

        private bool ParseHttpRequest(ref ReadOnlySequence<byte> buffer, bool isCompleted, out SequencePosition examined)
        {
            examined = buffer.End;

            var consumed = buffer.Start;
            var state = _state;

            if (!buffer.IsEmpty)
            {
                if (state == State.StartLine)
                {
                    if (Parser.ParseRequestLine(new ParsingAdapter(this), buffer, out consumed, out examined))
                    {
                        state = State.Headers;
                    }

                    buffer = buffer.Slice(consumed);
                }

                if (state == State.Headers)
                {
                    if (Parser.ParseHeaders(new ParsingAdapter(this), buffer, out consumed, out examined, out int consumedBytes))
                    {
                        state = State.Body;
                    }

                    buffer = buffer.Slice(consumed);
                }

                if (state != State.Body && isCompleted)
                {
                    ThrowUnexpectedEndOfData();
                }
            }
            else if (isCompleted)
            {
                return false;
            }

            _state = state;
            return true;
        }

        public void OnHeader(Span<byte> name, Span<byte> value)
        {
        }

        public async ValueTask OnReadCompletedAsync()
        {
            Writer.Commit();
            await Output.FlushAsync();
        }

        private static HtmlEncoder CreateHtmlEncoder()
        {
            var settings = new TextEncoderSettings(UnicodeRanges.BasicLatin, UnicodeRanges.Katakana, UnicodeRanges.Hiragana);
            settings.AllowCharacter('\u2014');  // allow EM DASH through
            return HtmlEncoder.Create(settings);
        }

        private static void ThrowUnexpectedEndOfData()
        {
            throw new InvalidOperationException("Unexpected end of data!");
        }

        private enum State
        {
            StartLine,
            Headers,
            Body
        }

        private struct ParsingAdapter : IHttpRequestLineHandler, IHttpHeadersHandler
        {
            public BenchmarkApplication RequestHandler;

            public ParsingAdapter(BenchmarkApplication requestHandler)
                => RequestHandler = requestHandler;

            public void OnHeader(Span<byte> name, Span<byte> value)
                => RequestHandler.OnHeader(name, value);

            public void OnStartLine(HttpMethod method, HttpVersion version, Span<byte> target, Span<byte> path, Span<byte> query, Span<byte> customMethod, bool pathEncoded)
                => RequestHandler.OnStartLine(method, version, target, path, query, customMethod, pathEncoded);
        }
    }

}