import * as React from 'react';
import { cn } from '@/lib/utils';

/**
 * Minimal `asChild` implementation: merges our props onto the single child
 * element so a Button can render as a Link without an extra wrapper node.
 */
export const Slot = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  function Slot({ children, className, ...props }, ref) {
    if (!React.isValidElement(children)) return null;

    const child = children as React.ReactElement<Record<string, unknown>>;
    const childProps = child.props;

    return React.cloneElement(child, {
      ...props,
      ...childProps,
      className: cn(className, childProps.className as string | undefined),
      ref,
    } as Record<string, unknown>);
  },
);
