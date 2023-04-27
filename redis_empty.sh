#!/bin/bash
redis-cli KEYS "*" | while read key; do
    redis-cli DEL $key
done