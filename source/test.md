---
title: Test Journal
author: Test User
date: 2024-11-15
---

# Test Journal Entry

This is a test file to verify your journal workflow installation is working correctly.

## Testing Tag Filter

This entry contains several tags: #testing #workflow #setup

You should see these tags appear in **blue** color and be indexed in the Tags section at the back of the PDF.

Multiple consecutive tags should also work: #success#installation#verification

## Testing Name Filter

This section mentions some people: Andrea, Rose, Luca, and Mila.

These names should appear in **red** color and be indexed in the People section.

Note: Only names in the `common_names` list in `filters/name-filter.lua` will be recognized.

## Testing Object References

Here are references to various objects that should be indexed:

- [Thinking Fast and Slow](../test-data/Books/Thinking%20Fast%20and%20Slow.md) - Should appear in Books index
- [Cognitive Bias](../test-data/Definitions/Cognitive%20Bias.md) - Should appear in Definitions index
- [Stanford University](../test-data/Organizations/Stanford%20University.md) - Should appear in Organizations index
- [Journal Workflow](../test-data/Projects/Journal%20Workflow.md) - Should appear in Projects index
- [Sarah Johnson](../test-data/People/Sarah%20Johnson.md) - Should appear in People index

## Testing Embedded Page Removal

The following standalone embed should be removed from the final PDF:

[Sample Page](../test-data/Pages/Sample%20Page.md)

But inline references like [Sample Page](../test-data/Pages/Sample%20Page.md) mentioned in text should remain.

## Testing Media Links

Note: To test images, place an image file in `assets/Images/Media/` and add a markdown image reference.

Videos embedded in the markdown should be converted to plain text (since they don't work in PDFs).

## Expected Results

After building this test file with `./build.sh source/test.md`, you should see:

1. **Tags in blue**: #testing, #workflow, #setup, #success, #installation, #verification
2. **Names in red**: Andrea, Rose, Luca, Mila
3. **Six indexes at the back**:
   - Books (Thinking Fast and Slow)
   - Definitions (Cognitive Bias)
   - Organizations (Stanford University)
   - People (Andrea, Rose, Luca, Mila, Sarah Johnson)
   - Projects (Journal Workflow)
   - Tags (all hashtags listed)
4. **Standalone embed removed**: The standalone "Sample Page" link should not appear
5. **Professional layout**: Proper margins, headers, page numbers

## Success!

If you see all of the above, your installation is working correctly!

You're now ready to process your own journal content.
