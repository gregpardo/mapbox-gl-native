#pragma once

#include <mbgl/util/type_list.hpp>
#include <mbgl/util/indexed_tuple.hpp>
#include <mbgl/util/range.hpp>
#include <mbgl/util/logging.hpp>


namespace mbgl {
namespace style {

/**
 * A statistics entry for a property
 */
template <class Type>
class StatsEntry {
public:
    optional<Type> max;
};

/**
 * Holder for paint property statistics,
 * calculated just before rendering
 *
 * <Ps> the DataDrivenPaintProperties in this collection
 */
template <class... Ps>
class PaintPropertyStatistics {
public:

    using Properties = TypeList<Ps...>;
    using Types = TypeList<StatsEntry<typename Ps::Type>...>;

    template <class TypeList>
    using Tuple = IndexedTuple<Properties, TypeList>;

    class Values : public Tuple<Types> {
    public:
        using Tuple<Types>::Tuple;
    };

    template <class P>
    auto max() const {
        auto value = maximums.template get<P>();
        return *value.max;
    }

    template <class P>
    void add(const float& value) {
        Log::Info(Event::General, "Value: %f", value);
        auto holder = maximums.template get<P>();
        holder.max = holder.max ? std::max(*holder.max, value) : value;
        Log::Info(Event::General, "Max: %f", *holder.max);
    }

    template <class P>
    void add(const Range<float>& value) {
        Log::Info(Event::General, "Value: %f <-> %f", value.min, value.max);
        add<P>(std::max(value.min, value.max));
    }

    template <class P, class T>
    void add(const T&) {
        //NOOP, not interested in these types
        Log::Info(Event::General, "Value: other type???");
    }

private:

    Values maximums;
};

} // namespace style
} // namespace mbgl
